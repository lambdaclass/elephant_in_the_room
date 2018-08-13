defmodule ElephantInTheRoomWeb.SiteControllerTest do
  use ElephantInTheRoomWeb.ConnCase
  alias ElephantInTheRoom.Sites.Post

  describe "markdown" do
    test "& input" do
      assert "<p>&amp;</p>\n" = Post.generate_markdown("&")
    end

    test "unsafe" do
      assert "<!-- raw HTML omitted -->\n" = Post.generate_markdown("<script>alert(\"hello world!\")</script>")
    end

  end
end
