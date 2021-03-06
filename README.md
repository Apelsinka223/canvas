# Canvas

For the application were used:
* PostgreSQL + Ecto as DB
* GraphQL + Absinthe for API
* ExUnit and ExMachina for tests

To start server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

## Interface

You can use graphiql console to work with application.  
Open [`localhost:4000/api/graphiql`](localhost:4000/api/graphiql) from your browser.

## Commands

1. Create a new field:
```graphql
mutation {
  create_field(width: 10, height: 10) { 
    id 
  }
}
```
You can pass width and height or not. If size params not passed, field would be flexible. Otherwise, field would have fixed size.  
Width and height have type PositiveInt, which mean that they should be > 0.

2. Add a rectangle to the field
```graphql
mutation($field_id: ID!) {
    add_rectangle(
        field_id: $field_id, 
        rectangle:{
            width: 5, 
            height:3, 
            start_point:{x:1, y:2}, 
            outline_char:"x", 
            fill_char:"o"
        }
    ) { 
        id width height body 
    }
}
```

3. Add flood_fill to the field
```graphql
mutation($field_id: ID!) {
    add_flood_fill(
        field_id: $field_id, 
        flood_fill:{
            start_point:{x:0, y:0}, 
            fill_char:"-"
        }
    ) { 
        id width height body 
    }
}
```

4. Print the field in a browser.  
Since the field body has a special format that is hard to perceive, you can print field in a browser.
   
Open `http://localhost:4000/print/<field_id>`

5. Check out the version history

History of the field changes is contained in the `fields_history` table.
