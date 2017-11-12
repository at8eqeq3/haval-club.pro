require 'google/apis'
require 'google/apis/youtube_v3'

class YTPlaylistDataSource < ::Nanoc::DataSource
  #CHANNEL_ID = 'UCCsdEKNd33Japt2Yp2AJdnA'
  CHANNEL_ID = 'UC98tcedR6gULv8_b70WJKyw' # Leo's videos
  identifier :yt_playlist
  def up
    @service = Google::Apis::YoutubeV3::YouTubeService.new
    @service.key = ENV['YTKEY']
  end

  def down
    #@service = nil
  end

  def items
    pls = []
    playlists = @service.list_playlists 'snippet,contentDetails', channel_id: CHANNEL_ID, max_results: 50
    playlists.items.each do |playlist|
      p = {}
      p[:id] = playlist.id
      p[:title] = playlist.snippet.title
      p[:description] = playlist.snippet.description
      p[:published_at] = playlist.snippet.published_at
      p[:items] = []
      playlist_items = @service.list_playlist_items 'snippet,status', playlist_id: playlist.id, max_results: 50
      playlist_items.items.each do |item|
        if item.status.privacy_status == 'public'
          i = {}
          i[:title] = item.snippet.title
          i[:description] = item.snippet.description
          i[:published_at] = item.snippet.published_at
          i[:thumbnail] = item.snippet.thumbnails.medium.url
          p[:items] << i
        end
      end
      pls << p
    end
    out = []
    pls.each do |p|
      out << new_item(p[:title], p, '/playlists/' + p[:id])
    end
    out
  end
end
