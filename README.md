<img width="1919" height="1023" alt="image" src="https://github.com/user-attachments/assets/d3c9d457-42df-4350-978b-bb0a37d72e38" />
 # Lab 6 - Simple Offline Music Player                                                                                                                          
                                                                                                                                                                 
  ## Cấu Trúc Code                                                                                                                                               
                                                                                                                                                                 
  ```txt                                                                                                                                                         
  lib/                                                                                                                                                           
  ├── main.dart                                                                                                                                                  
  ├── models/                                                                                                                                                    
  │   ├── song_model.dart                                                                                                                                        
  │   ├── playlist_model.dart                                                                                                                                    
  │   └── playback_state_model.dart                                                                                                                              
  ├── services/                                                                                                                                                  
  │   ├── audio_player_service.dart                                                                                                                              
  │   ├── playlist_service.dart                                                                                                                                  
  │   ├── permission_service.dart                                                                                                                                
  │   └── storage_service.dart                                                                                                                                   
  ├── providers/                                                                                                                                                 
  │   ├── audio_provider.dart                                                                                                                                    
  │   ├── playlist_provider.dart                                                                                                                                 
  │   └── theme_provider.dart                                                                                                                                    
  ├── screens/                                                                                                                                                   
  │   ├── home_screen.dart                                                                                                                                       
  │   ├── all_songs_screen.dart                                                                                                                                  
  │   ├── now_playing_screen.dart                                                                                                                                
  │   ├── playlist_screen.dart                                                                                                                                   
  │   └── settings_screen.dart                                                                                                                                   
  ├── widgets/                                                                                                                                                   
  │   ├── song_tile.dart                                                                                                                                         
  │   ├── mini_player.dart                                                                                                                                       
  │   ├── player_controls.dart                                                                                                                                   
  │   ├── progress_bar.dart                                                                                                                                      
  │   ├── playlist_card.dart                                                                                                                                     
  │   └── album_art.dart                                                                                                                                         
  └── utils/                                                                                                                                                     
      ├── constants.dart                                                                                                                                         
      ├── duration_formatter.dart                                                                                                                                
      └── color_extractor.dart                                                                                                                                   
                                                                                                                                                                 
  ## Các Phần Đã Làm Trong Code                                                                                                                                  
                                                                                                                                                                 
  ### 1. Models                                                                                                                                                  
                                                                                                                                                                 
  Code trong thư mục:                                                                                                                                            
                                                                                                                                                                 
  lib/models/                                                                                                                                                    
                                                                                                                                                                 
  Đã tạo các model chính:                                                                                                                                        
                                                                                                                                                                 
  - song_model.dart: lưu thông tin bài hát gồm id, title, artist, album, filePath, duration, albumArt, fileSize.                                                 
  - playlist_model.dart: lưu thông tin playlist gồm id, name, danh sách songIds, createdAt, updatedAt, coverImage.                                               
  - playback_state_model.dart: lưu trạng thái phát nhạc gồm position, duration và isPlaying.                                                                     
                                                                                                                                                                 
  ### 2. Services                                                                                                                                                
                                                                                                                                                                 
  Code trong thư mục:                                                                                                                                            
 
  lib/services/                                                                                                                                                  
                                                                                                                                                                 
  Đã làm các service xử lý logic chính:                                                                                                                          
                                                                                                                                                                 
  - audio_player_service.dart                                                                                                                                    
      - Dùng just_audio để phát nhạc.                                                                                                                            
      - Có các chức năng load audio, play, pause, stop, seek.                                                                                                    
      - Có chỉnh volume, speed và loop mode.                                                                                                                     
      - Có stream theo dõi position, duration và trạng thái đang phát.                                                                                           
  - playlist_service.dart                                                                                                                                        
      - Dùng on_audio_query để đọc danh sách bài hát từ thiết bị.                                                                                                
      - Có lấy tất cả bài hát.                                                                                                                                   
      - Có tìm bài theo artist, album và search theo từ khóa.                                                                                                    
  - permission_service.dart                                                                                                                                      
      - Xin quyền đọc nhạc/audio trên Android.                                                                                                                   
      - Hỗ trợ quyền READ_MEDIA_AUDIO cho Android mới.                                                                                                           
      - Có kiểm tra quyền và mở app settings nếu bị từ chối vĩnh viễn.                                                                                           
  - storage_service.dart                                                                                                                                         
      - Dùng shared_preferences để lưu dữ liệu local.                                                                                                            
      - Lưu playlist.                                                                                                                                            
      - Lưu bài hát phát cuối.                                                                                                                                   
      - Lưu vị trí phát cuối.                                                                                                                                    
      - Lưu recently played.                                                                                                                                     
      - Lưu shuffle, repeat, volume và speed.                                                                                                                    
                                                                                                                                                                 
  ### 3. Providers                                                                                                                                               
                                                                                                                                                                 
  Code trong thư mục:                                                                                                                                            
                                                                                                                                                                 
  lib/providers/                                                                                                                                                 
                                                                                                                                                                 
  Đã làm quản lý state bằng provider:                                                                                                                            
                                                                                                                                                                 
  - audio_provider.dart                                                                                                                                          
      - Quản lý playlist đang phát.                                                                                                                              
      - Quản lý bài hát hiện tại.                                                                                                                                
      - Xử lý play/pause.                                                                                                                                        
      - Xử lý next/previous.                                                                                                                                     
      - Xử lý seek.                                                                                                                                              
      - Xử lý shuffle.                                                                                                                                           
      - Xử lý repeat off/all/one.                                                                                                                                
      - Xử lý volume và playback speed.                                                                                                                          
      - Lưu bài vừa phát vào recently played.                                                                                                                    
      - Lưu vị trí phát.                                                                                                                                         
      - Có sleep timer.
  - playlist_provider.dart                                                                                                                                       
      - Tạo playlist.                                                                                                                                            
      - Đổi tên playlist.                                                                                                                                        
      - Xóa playlist.                                                                                                                                            
      - Thêm bài hát vào playlist.                                                                                                                               
      - Xóa bài hát khỏi playlist.                                                                                                                               
      - Kéo thả để đổi thứ tự bài hát trong playlist.                                                                                                            
  - theme_provider.dart                                                                                                                                          
      - Quản lý Dark Mode và Light Mode.                                                                                                                         
      - Lưu theme bằng shared_preferences.                                                                                                                       
                                                                                                                                                                 
  ### 4. Screens                                                                                                                                                 
                                                                                                                                                                 
  Code trong thư mục:                                                                                                                                            
                                                                                                                                                                 
  lib/screens/                                                                                                                                                   
                                                                                                                                                                 
  Đã làm các màn hình chính:                                                                                                                                     
                                                                                                                                                                 
  - home_screen.dart                                                                                                                                             
      - Hiển thị Home.                                                                                                                                           
      - Hiển thị Recently Played.                                                                                                                                
      - Hiển thị All Music.                                                                                                                                      
      - Có nút search.                                                                                                                                           
      - Khi bấm bài hát thì phát nhạc và mở Now Playing.                                                                                                         
  - all_songs_screen.dart                                                                                                                                        
      - Hiển thị toàn bộ bài hát.
      - Có sort theo Title, Artist, Album.                                                                                                                       
      - Có filter theo Artist, Album.                                                                                                                            
  - now_playing_screen.dart                                                                                                                                      
      - Hiển thị bài hát đang phát.                                                                                                                              
      - Hiển thị title, artist, album.                                                                                                                           
      - Hiển thị album art mặc định.                                                                                                                             
      - Có progress bar.                                                                                                                                         
      - Có play/pause, next, previous.                                                                                                                           
      - Có shuffle và repeat.                                                                                                                                    
      - Có chỉnh volume.                                                                                                                                         
      - Có chỉnh playback speed.                                                                                                                                 
  - playlist_screen.dart                                                                                                                                         
      - Hiển thị danh sách playlist.                                                                                                                             
      - Tạo playlist mới.                                                                                                                                        
      - Đổi tên playlist.                                                                                                                                        
      - Xóa playlist.
      - Mở chi tiết playlist.                                                                                                                                    
      - Thêm bài hát vào playlist.                                                                                                                               
      - Xóa bài hát khỏi playlist.                                                                                                                               
      - Kéo thả đổi thứ tự bài hát.                                                                                                                              
  - settings_screen.dart                                                                                                                                         
      - Bật/tắt Dark Mode.                                                                                                                                       
      - Chỉnh volume.                                                                                                                                            
      - Chỉnh playback speed.                                                                                                                                    
      - Cài Sleep Timer.                                                                                                                                         
      - Hiển thị thông tin app.                                                                                                                                  
                                                                                                                                                                 
  ### 5. Widgets                                                                                                                                                 
                                                                                                                                                                 
  Code trong thư mục:                                                                                                                                            
                                                                                                                                                                 
  lib/widgets/                                                                                                                                                   
                                                                                                                                                                 
  Đã tách các widget dùng lại:                                                                                                                                   
 
  - song_tile.dart                                                                                                                                               
      - Hiển thị một bài hát trong danh sách.                                                                                                                    
      - Có menu thêm bài vào playlist.                                                                                                                           
      - Có xem thông tin bài hát.                                                                                                                                
  - mini_player.dart                                                                                                                                             
      - Thanh phát nhạc nhỏ ở dưới màn hình.                                                                                                                     
      - Hiển thị bài đang phát.                                                                                                                                  
      - Có play/pause, previous, next.                                                                                                                           
  - player_controls.dart                                                                                                                                         
      - Cụm nút điều khiển phát nhạc.                                                                                                                            
      - Có shuffle, repeat, previous, play/pause, next.                                                                                                          
  - progress_bar.dart                                                                                                                                            
      - Thanh tiến trình phát nhạc.                                                                                                                              
      - Hiển thị thời gian hiện tại và tổng thời lượng.                                                                                                          
      - Cho phép seek.                                                                                                                                           
  - playlist_card.dart                                                                                                                                           
      - Widget hiển thị playlist.                                                                                                                                
  - album_art.dart                                                                                                                                               
      - Widget hiển thị ảnh album hoặc ảnh mặc định.                                                                                                             
                                                                                                                                                                 
  ### 6. Utils                                                                                                                                                   
                                                                                                                                                                 
  Code trong thư mục:                                                                                                                                            
 
  lib/utils/                                                                                                                                                     
                                                                                                                                                                 
  Đã có các file hỗ trợ:                                                                                                                                         
                                                                                                                                                                 
  - constants.dart                                                                                                                                               
      - Chứa AppColors.                                                                                                                                          
      - Quản lý màu theo Dark Mode và Light Mode.                                                                                                                
  - duration_formatter.dart                                                                                                                                      
      - Hỗ trợ format thời gian.                                                                                                                                 
  - color_extractor.dart                                                                                                                                         
      - Hỗ trợ xử lý màu từ ảnh album.                                                                                                                           
                                                                                                                                                                 
  ## Các Chức Năng Đã Hoàn Thành                                                                                                                                 
                                                                                                                                                                 
  - Đọc nhạc offline từ thiết bị.                                                                                                                                
  - Xin quyền đọc audio/storage.                                                                                                                                 
  - Hiển thị danh sách bài hát.                                                                                                                                  
  - Phát nhạc.                                                                                                                                                   
  - Tạm dừng nhạc.
  - Chuyển bài tiếp theo.                                                                                                                                        
  - Quay lại bài trước.                                                                                                                                          
  - Tua bài bằng progress bar.                                                                                                                                   
  - Hiển thị thời gian phát.                                                                                                                                     
  - Shuffle.                                                                                                                                                     
  - Repeat off/all/one.                                                                                                                                          
  - Chỉnh âm lượng.                                                                                                                                              
  - Chỉnh tốc độ phát.                                                                                                                                           
  - Mini player.
  - Now Playing screen.                                                                                                                                          
  - Search bài hát.                                                                                                                                              
  - Sort bài hát theo title, artist, album.                                                                                                                      
  - Filter bài hát theo artist, album.                                                                                                                           
  - Tạo playlist.                                                                                                                                                
  - Đổi tên playlist.                                                                                                                                            
  - Xóa playlist.                                                                                                                                                
  - Thêm bài hát vào playlist.                                                                                                                                   
  - Xóa bài hát khỏi playlist.                                                                                                                                   
  - Sắp xếp lại thứ tự bài trong playlist.                                                                                                                       
  - Recently Played.                                                                                                                                             
  - Lưu playlist.                                                                                                                                                
  - Lưu bài hát phát cuối.                                                                                                                                       
  - Lưu vị trí phát cuối.                                                                                                                                        
  - Lưu volume, speed, shuffle, repeat.                                                                                                                          
  - Dark Mode và Light Mode.                                                                                                                                     
  - Sleep Timer.
https://drive.google.com/file/d/1fbZnz10zv8lXGAFS7V-XASfEZteV8_Z-/view?usp=drive_link
