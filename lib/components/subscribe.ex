defmodule Blog.Subscribe do
  import Temple.Component

  def action(:prod) do
    "https://mitchellhanberg.us19.list-manage.com/subscribe/post?u=67fd268e3a3c997cf71adc99c&amp;id=a51ed9b39a"
  end

  def action(_) do
    "#"
  end

  render do
    div class: "mx-auto", id: "mc_embed_signup" do
      form action: action(Mix.env()),
           method: "post",
           id: "mc-embedded-subscribe-form",
           name: "mc-embedded-subscribe-form",
           class: "validate",
           target: "_blank",
           novalidate: true do
        div class: "flex flex-col", id: "mc_embed_signup_scroll" do
          label aria_hidden: "true",
                for: "mce-EMAIL",
                class: "hidden text-center pb-4 font-bold" do
            "Subscribe to stay updated!"
          end

          section class: "flex flex-col md:flex-row my-2" do
            input class:
                    "w-full text-evergreen-700 focus:focus-ring-400 bg-white py-2 px-4 flex-grow rounded-lg md:rounded-r-none mb-2 md:mb-0",
                  type: "email",
                  value: "",
                  name: "EMAIL",
                  id: "mce-EMAIL",
                  aria_label: "Email",
                  placeholder: "you@example.com",
                  required: true

            div class: "hidden", aria_hidden: "true" do
              input type: "text",
                    name: "b_67fd268e3a3c997cf71adc99c_a51ed9b39a",
                    tabindex: "-1",
                    value: ""
            end

            div do
              input type: "submit",
                    value: "Subscribe",
                    name: "subscribe",
                    id: "mc-embedded-subscribe",
                    class:
                      "py-2 px-8 bg-evergreen-700 text-white cursor-pointer flex-shrink-0 focus:focus-ring-400 rounded-lg md:rounded-l-none"

              input type: "checkbox",
                    id: "group_1",
                    name: "group[4006][1]",
                    value: "1",
                    checked: true,
                    class: "hidden"
            end
          end
        end
      end
    end
  end
end
