defmodule Blog.PostLayout do
  import Blog
  use Tableau.Layout, layout: Blog.RootLayout

  def template(assigns) do
    ~L"""
    <section class="mt-4">
      <div class="border-b pb-4 max-w-2xl mx-auto">
        <h1 class="text-2xl md:text-3xl mb-4">{{ page.title }}</h1>
        <div class="text-sm italic">{{ page.date | date: "%B %d, %Y" }}
          {% if page.updated %}
            • Updated on {{ page.updated | to_date_time | date: "%B %d, %Y" }}
          {% endif %}
          • {{ page | reading_time }}
          • <a class="font-normal" href="https://twitter.com/mitchhanberg" target="_blank">@mitchhanberg</a>
          • <a class="font-normal" href="https://plausible.io/share/mitchellhanberg.com?auth=FZC88nN2lEqr_pXc_5OYI&entry_page={{page.permalink}}&period=all" target="_blank">Analytics</a>
        </div>
        {% if page.tags.size > 0 %}
          <div class="mt-4 text-sm">
            Tags: <span>{{ page.tags | tags | h }}</span>
          </div>
        {% endif %}
      </div>
      {% if page.img %}
        <p class="mt-4 py-4 mb-16">
          <img class="mx-auto bg-transparent" src="{{ page.img | absolute_url }}" alt="Pointless hero image, reminiscent of medium posts">
          <p class="text-center text-xs">{{page.image_desc}}</p>
        </p>
        <article class="post mx-auto">
      {% else %}
        <article class="post my-4 mx-auto">
      {% endif %}
        {{ inner_content | render }}

        </article>
        <div class="max-w-2xl mx-auto mt-16">
          <hr>

          {% if page.reviewers %}
          <p class="italic mb-8">
            Thank you to {{ page.reviewers | array_to_sentence_string }} for their help reviewing this article.
          </p>
          {% endif %}

          <div class="bg-evergreen-800 p-4 rounded mb-4">
            <p>If you want to stay current with what I'm working on and articles I write, join my mailing list!</p>

            <p class="text-sm">I seldom send emails, and I will <strong class="text-white">never</strong> share your email address with anyone else.</p>

            {% if tableau.environment == 'prod' %}
            {% render "subscribe" %}
            {% endif %}
          </div>
        </div>
    </section>

    <script>
      // Mitch.anchorifyHeaders();
      Mitch.wrapTable();
    </script>
    """
  end
end
