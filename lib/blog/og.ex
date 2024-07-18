defmodule Blog.Og do
  import Blog

  def template(assigns) do
    ~L"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta charset="utf-8" />
        <style>
          {{ "_site/css/site.css" | app_css }}
        </style>
      </head>
      <body class="bg-evergreen-900 font-sans h-screen">
        <div class="flex flex-col h-full justify-between">
          <div class="flex justify-between items-center gap-4 p-8">
            <div class="p-1">
            {% render "logo" %}
            </div>
            <span class="text-3xl -mt-0.5 font-semibold">Mitchell Hanberg</span>
          </div>
          <div class="flex justify-end items-center p-8">
            <span class="text-3xl font-semibold">
              {{ post.date | date: "%B %d, %Y"}}
            </span>
          </div>
        </div>
        <div class="grid justify-center items-center h-screen w-screen absolute top-0 border-white border-[15px]">
          <div class="flex items-end px-12">
            <div class="text-7xl font-bold leading-[125%]">{{ post.title }}</div>
          </div>
        </div>
      </body>
    </html>
    """
  end
end
