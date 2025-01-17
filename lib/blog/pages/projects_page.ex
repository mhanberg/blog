defmodule Blog.ProjectsPage do
  use Tableau.Page,
    layout: Blog.PageLayout,
    permalink: "/projects",
    title: "Projects"

  import Blog

  def template(assigns) do
    ~L"""
    <div class="max-w-2xl mx-auto">
      <h1 class="md:text-5xl md:mb-8">Projects</h1>

      <p class="mt-4">
      I have created and maintained quite a few projects in the last few years. Open source has been an amazing outlet for improving my skills and exploring new technologies.
      </p>

      {% for project in data.projects %}
        <div class="mt-8">
          <div class="flex justify-between">
            <h2 class="text-xl text-white no-underline">
              {{ project.name }}
            </h2>
            <span class="text-sm italic">{{ project.role }}</span>
          </div>

          <div class="mt-2 text-base">
            Homepage: <a class="font-normal" target="_blank" href="{{project.link}}">{{project.link}}</a>
          </div>


          <p>{{ project.description | markdownify }}</p>
        </div>
      {% endfor %}
    </div>
    """
  end
end
