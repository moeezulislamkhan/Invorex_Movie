# MUX Video API Integration Guide

## ✅ What's Been Fixed

Your Invorex Movies app now has **full video playback support** using the MUX Video API. Here's what was added:

### 1. **Video Player Dependencies**
   - Added `video_player` and `chewie` packages to handle HLS streaming
   - Supports fullscreen, playback speed control, and muting

### 2. **Enhanced MUX Service** (`lib/services/mux_video_api_service.dart`)
   - `getVideoDetails(videoId)` → Fetch video metadata from MUX
   - `getPlaybackUrl(videoId)` → Get the HLS stream URL for playback

### 3. **New VideoPlayerScreen** (`lib/screens/video_player_screen.dart`)
   - Full-featured video player with Chewie UI
   - Handles loading, errors, and video initialization
   - Supports orientation changes and playback controls

### 4. **Updated WatchScreen** (`lib/screens/watch_screen.dart`)
   - Now supports **MUX videos** via `videoId` parameter
   - Falls back to **YouTube trailers** via `trailerKey` parameter
   - Better error handling and loading states

---

## 🚀 How to Use in Your App

### Step 1: Update Your Models
Modify your models to include MUX video IDs. Example for `MediaItem`:

```dart
class MediaItem {
  final String id;
  final String title;
  final String? description;
  final String? posterPath;
  final String? backdropPath;
  final String? trailerKey;  // YouTube trailer (optional)
  final String? muxVideoId;  // NEW: MUX video ID for playback
  
  MediaItem({
    required this.id,
    required this.title,
    // ... other fields
    this.trailerKey,
    this.muxVideoId,
  });
}
```

### Step 2: Update Navigation Calls
When navigating to the watch screen, pass the video ID:

```dart
// In your details_screen.dart or similar
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => WatchScreen(
      title: mediaItem.title,
      videoId: mediaItem.muxVideoId,      // ← MUX video ID
      trailerKey: mediaItem.trailerKey,   // ← YouTube fallback
    ),
  ),
);
```

### Step 3: Populate MUX Video IDs
You have two options:

**Option A: From MUX Dashboard**
- Visit your MUX dashboard
- Get video IDs from your uploaded videos
- Store them in your backend/database

**Option B: Fetch from MUX API**
```dart
final muxService = context.read<MuxVideoApiService>();
final videos = await muxService.getVideos(limit: 10);
// Extract video IDs and use them
```

---

## 📝 Example Usage

### Complete Navigation Example
```dart
void _watchMovie(MediaItem movie) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => WatchScreen(
        title: movie.title,
        videoId: movie.muxVideoId,       // For in-app playback
        trailerKey: movie.trailerKey,    // YouTube fallback
      ),
    ),
  );
}
```

### Handling Both MUX and YouTube
The updated `WatchScreen` now intelligently handles:
- ✅ **MUX Videos**: Streams via HLS (in-app playback)
- ✅ **YouTube Trailers**: Opens in external app
- ✅ **Fallback**: Shows error if neither is available

---

## 🔧 Configuration

Your MUX API is already configured in `lib/config/app_config.dart`:
```dart
static const String muxEnvironmentKey = 'sl8n1m2ua5tglem2ntg9nhd0f';
static const String muxBaseUrl = 'https://api.mux.com';
static const String muxVideoApiPath = '/video/v1';
```

---

## ⚠️ Common Issues & Solutions

### Issue: "Video Player Initialization Fails"
**Solution**: Ensure your video URL is valid and MUX video has a public playback ID
```dart
// Check if video has playback_ids in MUX dashboard
```

### Issue: "HLS Stream Not Loading"
**Solution**: Verify the playback URL format is correct
```
https://stream.mux.com/{playback_id}.m3u8
```

### Issue: "Package Not Found Errors"
**Solution**: Run these commands
```bash
flutter pub get
flutter pub upgrade video_player chewie
flutter clean
flutter pub get
```

---

## 📱 Testing Checklist

- [ ] Run `flutter pub get` to install new packages
- [ ] Build the app: `flutter build apk` (Android) or `flutter build ios` (iOS)
- [ ] Navigate to a movie/series with a MUX video ID
- [ ] Tap the "Play Video" button
- [ ] Verify video loads and plays in fullscreen
- [ ] Test playback controls (play, pause, speed, volume)
- [ ] Test rotating device to landscape
- [ ] Test fallback to YouTube trailer if MUX video unavailable

---

## 🎯 Next Steps

1. **Update your data models** to include `muxVideoId`
2. **Modify navigation calls** to pass video IDs
3. **Test with real MUX videos** from your dashboard
4. **Deploy and monitor** playback performance

## 📚 Resources

- MUX Documentation: https://docs.mux.com/
- Flutter Video Player: https://pub.dev/packages/video_player
- Chewie Player: https://pub.dev/packages/chewie

---

**Questions?** Check the implementation in:
- Service: `lib/services/mux_video_api_service.dart`
- Player: `lib/screens/video_player_screen.dart`
- Integration: `lib/screens/watch_screen.dart`
