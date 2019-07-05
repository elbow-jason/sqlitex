defmodule Sqlitex.ExtensionsTest do
  use ExUnit.Case

  test "an fts5 table can be created" do
    assert {:ok, db} = Sqlitex.open(":memory:")

    assert :ok =
             Sqlitex.exec(
               db,
               "CREATE VIRTUAL TABLE blogs USING fts5(author_email, title, body, tokenize = 'porter ascii');"
             )

    assert :ok =
             Sqlitex.exec(db, """
             INSERT INTO blogs (
               author_email,
               title,
               body
             ) VALUES (
               'jason.goldberger@dockyard.com',
               'Oh look text search',
               'It was a dark and stormy night...'
             );
             """)

    assert {:ok, [row1]} =
             Sqlitex.query(db, """
             SELECT * FROM blogs WHERE blogs MATCH 'dark';
             """)

    assert row1 == [
             author_email: "jason.goldberger@dockyard.com",
             title: "Oh look text search",
             body: "It was a dark and stormy night..."
           ]
  end
end
