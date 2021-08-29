defmodule Blog.Logo do
  import Temple.Component

  import Phoenix.HTML

  render do
    raw("""
    <svg class="h-8 md:h-12" viewBox="0 0 131 68" xmlns="http://www.w3.org/2000/svg"><g fill="none" fill-rule="evenodd"><path fill="#1A2B2C" d="M-29-15H995v1024H-29z"/><path d="M0 68L49.595 0c20.138 25.259 30.763 37.888 31.874 37.888 1.111 0 6.136-4.593 15.075-13.778L131 68H0z" fill="#2D4648"/><path d="M21 68l14.85-19.065c5.596 5.874 8.733 8.81 9.409 8.81.676 0 6.321-6.581 16.934-19.745L88 68H21z" fill="#4A6668"/></g></svg>
    """)
  end
end
