defmodule CanvasWeb.Resolvers.FieldsTest do
  use CanvasWeb.ConnCase
  use CanvasWeb.SubscriptionCase

  alias Canvas.Repo
  alias Canvas.Fields.Field
  alias Canvas.Repo
  alias CanvasWeb.Socket
  alias Ecto.UUID

  describe "fields/2" do
    setup do
      query = """
      query {
        fields {
          id
        }
      }
      """

      {:ok, query: query}
    end

    test "return fields list, ordered_by inserted_at desc", %{conn: conn, query: query} do
      %{id: field_id1} = create(:field, inserted_at: ~U[2020-01-02 00:00:00Z])
      %{id: field_id2} = create(:field, inserted_at: ~U[2020-02-01 00:00:00Z])

      res = post_query(conn, query)

      assert %{
               "data" => %{
                 "fields" => [
                   %{
                     "id" => ^field_id2
                   },
                   %{
                     "id" => ^field_id1
                   }
                 ]
               }
             } = json_response(res, 200)
    end

    test "when there are no field, return empty list", %{conn: conn, query: query} do
      res = post_query(conn, query)

      assert %{
               "data" => %{
                 "fields" => []
               }
             } = json_response(res, 200)
    end
  end

  describe "field/2" do
    setup do
      query = """
      query($field_id: Uuid!) {
        field(field_id: $field_id) {
          id width height body
        }
      }
      """

      {:ok, query: query}
    end

    test "return field", %{conn: conn, query: query} do
      %{id: field_id} =
        create(
          :field,
          width: 1,
          height: 2,
          body: %{
            {0, 0} => "x"
          },
          inserted_at: ~U[2020-02-01 00:00:00Z]
        )

      res = post_query(conn, query, %{"field_id" => field_id})

      assert %{
               "data" => %{
                 "field" => %{
                   "id" => ^field_id,
                   "width" => 1,
                   "height" => 2,
                   "body" => "\"{\\\"0,0\\\":\\\"x\\\"}\""
                 }
               }
             } = json_response(res, 200)
    end

    test "when field doesn't exist, return error", %{conn: conn, query: query} do
      res = post_query(conn, query, %{"field_id" => UUID.generate()})

      assert %{
               "errors" => [
                 %{
                   "message" => "field_not_found"
                 }
               ]
             } = json_response(res, 200)
    end
  end

  describe "create_field/2" do
    setup do
      query = """
      mutation($width: PositiveInt, $height: PositiveInt) {
        create_field(width: $width, height: $height) {
          id width height body
        }
      }
      """

      field_created_subscription = """
      subscription {
        field_created {
          id
        }
      }
      """

      {:ok, query: query, field_created_subscription: field_created_subscription}
    end

    test "creates field", %{conn: conn, query: query} do
      res = post_query(conn, query, %{"width" => 1, "height" => 2})

      assert %{
               "data" => %{
                 "field" => %{
                   "id" => field_id,
                   "width" => 1,
                   "height" => 2,
                   "body" => "\"{}\""
                 }
               }
             } = json_response(res, 200)

      assert %{
               width: 1,
               height: 2,
               body: %{}
             } = Repo.get(Field, field_id)
    end

    test "push created field to subscription",
         %{
           conn: conn,
           query: query,
           field_created_subscription: field_created_subscription,
           field: %{id: field_id}
         } do
      {:ok, socket} = join_to_socket(Socket)

      sub_field_created = subscribe_on_query(socket, field_created_subscription)

      res =
        post_query(
          conn,
          query,
          %{
            "field_id" => field_id,
            "flood_fill" => %{
              "start_point" => %{"x" => 0, "y" => 0},
              "fill_char" => "-"
            }
          }
        )

      json_response(res, 200)

      assert_push "subscription:data", %{
        result: %{data: %{"field_created" => %{"id" => ^field_id}}},
        subscriptionId: ^sub_field_created
      }
    end

    test "when params are invalid, return error", %{conn: conn, query: query} do
      res = post_query(conn, query, %{"width" => "1"})

      assert %{
               "errors" => [
                 %{
                   "message" => "Argument \"width\" has invalid value $width."
                 }
               ]
             } = json_response(res, 200)
    end
  end

  describe "add_rectangle/2" do
    setup do
      field = create(:field)

      query = """
      mutation($field_id: Uuid!, $rectangle: Rectangle!) {
        add_rectangle(field_id: $field_id, rectangle: $rectangle) {
          id width height body
        }
      }
      """

      field_subscription = """
      subscription($field_id: ID) {
        field(field_id: $field_id) {
          id
        }
      }
      """

      fields_subscription = """
      subscription {
        fields {
          id
        }
      }
      """

      {:ok,
       query: query,
       field_subscription: field_subscription,
       fields_subscription: fields_subscription,
       field: field}
    end

    test "return updated field", %{conn: conn, query: query, field: field} do
      res =
        post_query(
          conn,
          query,
          %{
            "field_id" => field.id,
            "rectangle" => %{
              "width" => 1,
              "height" => 2,
              "start_point" => %{"x" => 0, "y" => 0},
              "fill_char" => "-",
              "outline_char" => "x"
            }
          }
        )

      assert %{
               "data" => %{
                 "add_rectangle" => %{
                   "id" => field_id,
                   "width" => 1,
                   "height" => 2,
                   "body" => "\"{\\\"0,0\\\":\\\"x\\\",\\\"0,1\\\":\\\"x\\\"}\""
                 }
               }
             } = json_response(res, 200)

      assert %{
               width: 1,
               height: 2,
               body: %{}
             } = Repo.get(Field, field_id)
    end

    test "push updated field to subscription",
         %{
           conn: conn,
           query: query,
           field_subscription: field_subscription,
           fields_subscription: fields_subscription,
           field: %{id: field_id}
         } do
      {:ok, socket} = join_to_socket(Socket)

      sub_field = subscribe_on_query(socket, field_subscription, %{"field_id" => field_id})
      sub_fields = subscribe_on_query(socket, fields_subscription)

      res =
        post_query(
          conn,
          query,
          %{
            "field_id" => field_id,
            "rectangle" => %{
              "width" => 1,
              "height" => 2,
              "start_point" => %{"x" => 0, "y" => 0},
              "fill_char" => "-",
              "outline_char" => "x"
            }
          }
        )

      json_response(res, 200)

      assert_push "subscription:data", %{
        result: %{data: %{"field_updated" => %{"id" => ^field_id}}},
        subscriptionId: ^sub_field
      }

      assert_push "subscription:data", %{
        result: %{data: %{"fields_updated" => %{"id" => ^field_id}}},
        subscriptionId: ^sub_fields
      }
    end

    test "when drawing is invalid, return error", %{conn: conn, query: query} do
      field = create(:field, width: 1, height: 1, size_fixed: true)

      res =
        post_query(
          conn,
          query,
          %{
            "field_id" => field.id,
            "rectangle" => %{
              "width" => 1,
              "height" => 2,
              "start_point" => %{"x" => 10, "y" => 10},
              "fill_char" => "-",
              "outline_char" => "x"
            }
          }
        )

      assert %{
               "errors" => [
                 %{
                   "message" => "out_of_range"
                 }
               ]
             } = json_response(res, 200)
    end

    test "when params are invalid, return error", %{conn: conn, query: query} do
      res = post_query(conn, query, %{"width" => "1"})

      assert %{
               "errors" => [
                 %{
                   "message" => "Argument \"width\" has invalid value $width."
                 }
               ]
             } = json_response(res, 200)
    end
  end

  describe "add_flood_fill/2" do
    setup do
      field = create(:field)

      query = """
      mutation($field_id: Uuid!, $flood_fill: FloodFill!) {
        add_flood_fill(field_id: $field_id, flood_fill: $flood_fill) {
          id width height body
        }
      }
      """

      field_subscription = """
      subscription($field_id: ID) {
        field(field_id: $field_id) {
          id
        }
      }
      """

      fields_subscription = """
      subscription {
        fields {
          id
        }
      }
      """

      {:ok,
       query: query,
       field_subscription: field_subscription,
       fields_subscription: fields_subscription,
       field: field}
    end

    test "return updated field", %{conn: conn, query: query, field: field} do
      res =
        post_query(
          conn,
          query,
          %{
            "field_id" => field.id,
            "flood_fill" => %{
              "start_point" => %{"x" => 0, "y" => 0},
              "fill_char" => "-"
            }
          }
        )

      assert %{
               "data" => %{
                 "add_rectangle" => %{
                   "id" => field_id,
                   "width" => 1,
                   "height" => 2,
                   "body" => "\"{\\\"0,0\\\":\\\"x\\\",\\\"0,1\\\":\\\"x\\\"}\""
                 }
               }
             } = json_response(res, 200)

      assert %{
               width: 1,
               height: 2,
               body: %{}
             } = Repo.get(Field, field_id)
    end

    test "push updated field to subscription",
         %{
           conn: conn,
           query: query,
           field_subscription: field_subscription,
           fields_subscription: fields_subscription,
           field: %{id: field_id}
         } do
      {:ok, socket} = join_to_socket(Socket)

      sub_field = subscribe_on_query(socket, field_subscription, %{"field_id" => field_id})
      sub_fields = subscribe_on_query(socket, fields_subscription)

      res =
        post_query(
          conn,
          query,
          %{
            "field_id" => field_id,
            "flood_fill" => %{
              "start_point" => %{"x" => 0, "y" => 0},
              "fill_char" => "-"
            }
          }
        )

      json_response(res, 200)

      assert_push "subscription:data", %{
        result: %{data: %{"field_updated" => %{"id" => ^field_id}}},
        subscriptionId: ^sub_field
      }

      assert_push "subscription:data", %{
        result: %{data: %{"fields_updated" => %{"id" => ^field_id}}},
        subscriptionId: ^sub_fields
      }
    end

    test "when drawing is invalid, return error", %{conn: conn, query: query} do
      field = create(:field, width: 1, height: 1, size_fixed: true)

      res =
        post_query(
          conn,
          query,
          %{
            "field_id" => field.id,
            "flood_fill" => %{
              "start_point" => %{"x" => 10, "y" => 10},
              "fill_char" => "-"
            }
          }
        )

      assert %{
               "errors" => [
                 %{
                   "message" => "out_of_range"
                 }
               ]
             } = json_response(res, 200)
    end

    test "when params are invalid, return error", %{conn: conn, query: query} do
      res = post_query(conn, query, %{"width" => "1"})

      assert %{
               "errors" => [
                 %{
                   "message" => "Argument \"width\" has invalid value $width."
                 }
               ]
             } = json_response(res, 200)
    end
  end
end
