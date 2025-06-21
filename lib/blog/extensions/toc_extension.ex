defmodule Blog.TOCExtension do
  use Tableau.Extension, priority: 200, key: :oc, enabled: true

  @impl Tableau.Extension
  def pre_build(token) do
    posts =
      for post <- token.posts do
        doc = MDEx.parse_document!(post.body)
        toc = scan_headings(List.wrap(doc[MDEx.Heading]))

        Map.put(post, :toc, toc)
      end

    {:ok, Map.put(token, :posts, posts)}
  end

  defp scan_headings([]) do
    []
  end

  defp scan_headings(headings) do
    [current | rest] = headings

    case Enum.split_while(rest, &(&1.level > current.level)) do
      {[], []} ->
        [{current, []}]

      {[], rest} ->
        [{current, []} | scan_headings(rest)]

      {rank, []} ->
        [{current, scan_headings(rank)}]

      {rank, rest} ->
        [{current, scan_headings(rank)} | scan_headings(rest)]
    end
  end
end
