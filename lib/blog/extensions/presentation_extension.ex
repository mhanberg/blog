defmodule Blog.PresentationExtension do
  use Tableau.Extension, priority: 200, key: :presentation, enabled: true
  import Schematic

  alias Tableau.Extension.Common

  @impl Tableau.Extension
  def config(input) do
    unify(
      map(%{
        optional(:enabled, true) => bool(),
        optional(:dir, ["_presentations"]) => list(str())
      }),
      input
    )
  end

  @impl Tableau.Extension
  def pre_build(token) do
    %{extensions: %{presentation: %{config: config}}} = token

    presentations =
      config.dir
      |> List.wrap()
      |> Enum.flat_map(fn path ->
        path
        |> Path.join("**/*.md")
        |> Common.paths()
      end)
      |> Common.entries(fn entry ->
        %{
          path: path,
          front_matter: front_matter,
          pre_convert_body: body
        } = entry

        slides = extract_slides(body, token.site.config.markdown[:mdex])

        for {slide, idx} <- Enum.with_index(slides, 1) do
          body = MDEx.to_markdown!(slide)

          build(path, front_matter, idx, Enum.count(slides), body, config, fn assigns ->
            cols =
              for col <- extract_columns(slide, assigns.site.config.markdown[:mdex]) do
                separate_header_and_body(col)
              end

            [
              ~S|<div class="blog-slide-cols">|,
              for {heading, subheading, body} <- cols do
                [
                  ~S|<div class="blog-slide-col">|,
                  if heading && is_nil(body) do
                    [
                      ~S|<div class="blog-slide-col-title">|,
                      MDEx.to_html!(heading, assigns.site.config.markdown[:mdex]),
                      ~S|</div>|
                    ]
                  else
                    []
                  end,
                  if heading && subheading && is_nil(body) do
                    [
                      ~S|<div class="blog-slide-col-subtitle">|,
                      MDEx.to_html!(subheading, assigns.site.config.markdown[:mdex]),
                      ~S|</div>|
                    ]
                  else
                    []
                  end,
                  if heading && body do
                    [
                      ~S|<div class="blog-slide-col-heading">|,
                      MDEx.to_html!(heading, assigns.site.config.markdown[:mdex]),
                      ~S|</div>|
                    ]
                  else
                    []
                  end,
                  if body do
                    [
                      ~S|<div class="blog-slide-col-body">|,
                      ~S|<div class="blog-slide-col-body-content prose dark:prose-invert h-full max-w-none prose-a:text-fallout-green text-[32px]">|,
                      MDEx.to_html!(body, assigns.site.config.markdown[:mdex]),
                      ~S|</div>|,
                      ~S|</div>|
                    ]
                  else
                    []
                  end,
                  ~S|</div>|
                ]
              end,
              ~S|</div>|
            ]
          end)
        end
      end)
      |> List.flatten()

    {:ok, Map.put(token, :presentations, presentations)}
  end

  @impl Tableau.Extension
  def pre_render(token) do
    graph =
      Tableau.Graph.insert(
        token.graph,
        for page <- token.presentations do
          %Tableau.Page{
            parent: page.layout,
            permalink: page.permalink,
            template: page.renderer,
            opts: page
          }
        end
      )

    {:ok, Map.put(token, :graph, graph)}
  end

  defp build(filename, front_matter, slide, length, body, presentation_config, renderer) do
    front_matter
    |> Map.put(:__tableau_presentation_extension__, true)
    |> Map.put(:body, body)
    |> Map.put(:slide, slide)
    |> Map.put(:length, length)
    |> Map.put(:file, filename)
    |> Map.put(:renderer, renderer)
    |> Map.put(:layout, Module.concat([front_matter[:layout]]))
    |> Common.build_permalink(presentation_config)
  end

  defp extract_slides(body, mdex_opts) do
    %MDEx.Document{nodes: nodes} = MDEx.parse_document!(body, mdex_opts)

    for node <- nodes, reduce: [[]] do
      [page | rest] ->
        case node do
          %MDEx.ThematicBreak{} ->
            [[], MDEx.Document.wrap(Enum.reverse(page)) | rest]

          _ ->
            [[node | page] | rest]
        end
    end
    |> then(fn
      [[] | slides] -> slides
      [slide | slides] -> [Enum.reverse(slide) | slides]
    end)
    |> Enum.map(&MDEx.Document.wrap/1)
    |> Enum.reverse()
  end

  defp extract_columns(%MDEx.Document{nodes: nodes}, _mdex_opts) do
    for node <- nodes, reduce: [[]] do
      [page | rest] ->
        case node do
          %MDEx.Paragraph{nodes: [%MDEx.Text{literal: "==="}]} ->
            [[], Enum.reverse(page) | rest]

          _ ->
            [[node | page] | rest]
        end
    end
    |> then(fn
      [[] | slides] -> slides
      [slide | slides] -> [Enum.reverse(slide) | slides]
    end)
    |> Enum.reverse()
  end

  defp separate_header_and_body([%MDEx.Heading{} = heading, %MDEx.Heading{} = subheading]) do
    {MDEx.Document.wrap(heading), MDEx.Document.wrap(subheading), nil}
  end

  defp separate_header_and_body([%MDEx.Heading{} = heading]) do
    {MDEx.Document.wrap(heading), nil, nil}
  end

  defp separate_header_and_body([%MDEx.Heading{} = heading | rest]) do
    {MDEx.Document.wrap(heading), nil, MDEx.Document.wrap(rest)}
  end

  defp separate_header_and_body(doc) do
    {nil, nil, doc}
  end
end
