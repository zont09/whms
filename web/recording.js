(function() {
  let mediaRecorder = null;
  let recordedChunks = [];
  let recordingStream = null;

  window.FlutterRecording = {
    // Lấy stream từ video element
    getStreamFromVideo: function(videoElementId) {
      try {
        const videoElement = document.querySelector(`video[id="${videoElementId}"]`);
        if (!videoElement) {
          console.error('[FlutterRecording] Video element not found');
          return null;
        }

        const stream = videoElement.srcObject;
        if (!stream) {
          console.error('[FlutterRecording] No stream in video element');
          return null;
        }

        return stream;
      } catch (error) {
        console.error('[FlutterRecording] Error getting stream:', error);
        return null;
      }
    },

    // Bắt đầu recording với streamId
    startRecordingWithStreamId: async function(streamId) {
      try {
        console.log('[FlutterRecording] Starting recording with streamId:', streamId);

        // Tìm video element có stream này
        const videoElements = document.querySelectorAll('video');
        let stream = null;

        for (const video of videoElements) {
          if (video.srcObject && video.srcObject.id === streamId) {
            stream = video.srcObject;
            break;
          }
        }

        if (!stream) {
          // Thử lấy từ tất cả các stream đang có
          const allVideos = Array.from(videoElements);
          if (allVideos.length > 0 && allVideos[0].srcObject) {
            stream = allVideos[0].srcObject;
            console.log('[FlutterRecording] Using first available stream');
          }
        }

        if (!stream) {
          return {
            success: false,
            error: 'Cannot find MediaStream'
          };
        }

        return await this.startRecording(stream);
      } catch (error) {
        console.error('[FlutterRecording] Error in startRecordingWithStreamId:', error);
        return {
          success: false,
          error: error.message || error.toString()
        };
      }
    },

    startRecording: async function(stream) {
      try {
        console.log('[FlutterRecording] Starting recording...', stream);

        // Kiểm tra stream
        if (!stream || !stream.getTracks) {
          return {
            success: false,
            error: 'Invalid MediaStream object'
          };
        }

        const tracks = stream.getTracks();
        console.log('[FlutterRecording] Stream tracks:', tracks.length);

        if (tracks.length === 0) {
          return {
            success: false,
            error: 'Stream has no tracks'
          };
        }

        // Kiểm tra MediaRecorder support
        if (!window.MediaRecorder) {
          return {
            success: false,
            error: 'MediaRecorder API không được hỗ trợ trên trình duyệt này'
          };
        }

        // Dừng recording cũ nếu có
        if (mediaRecorder && mediaRecorder.state !== 'inactive') {
          mediaRecorder.stop();
        }

        // Reset chunks
        recordedChunks = [];
        recordingStream = stream;

        // Tạo MediaRecorder mới
        const options = { mimeType: 'video/webm;codecs=vp8,opus' };

        // Fallback nếu codec không support
        if (!MediaRecorder.isTypeSupported(options.mimeType)) {
          options.mimeType = 'video/webm';
        }

        if (!MediaRecorder.isTypeSupported(options.mimeType)) {
          options.mimeType = '';
        }

        mediaRecorder = new MediaRecorder(stream, options);
        console.log('[FlutterRecording] Using mimeType:', mediaRecorder.mimeType);

        // Handle data available
        mediaRecorder.ondataavailable = function(event) {
          if (event.data && event.data.size > 0) {
            recordedChunks.push(event.data);
            console.log('[FlutterRecording] Chunk recorded:', event.data.size, 'bytes');
          }
        };

        // Handle stop
        mediaRecorder.onstop = function() {
          console.log('[FlutterRecording] Recording stopped. Total chunks:', recordedChunks.length);
          console.log('[FlutterRecording] Total size:',
            recordedChunks.reduce((sum, chunk) => sum + chunk.size, 0), 'bytes');
        };

        // Handle error
        mediaRecorder.onerror = function(event) {
          console.error('[FlutterRecording] MediaRecorder error:', event.error);
        };

        // Start recording (lưu mỗi 1 giây)
        mediaRecorder.start(1000);
        console.log('[FlutterRecording] MediaRecorder started, state:', mediaRecorder.state);

        return {
          success: true,
          message: 'Recording started'
        };

      } catch (error) {
        console.error('[FlutterRecording] Error starting recording:', error);
        return {
          success: false,
          error: error.message || error.toString()
        };
      }
    },

    stopRecording: function() {
      return new Promise((resolve) => {
        if (mediaRecorder && mediaRecorder.state !== 'inactive') {
          mediaRecorder.onstop = () => {
            console.log('[FlutterRecording] Recording stopped via promise');
            resolve(true);
          };
          mediaRecorder.stop();
        } else {
          console.log('[FlutterRecording] No active recording to stop');
          resolve(false);
        }
      });
    },

    getRecordingState: function() {
      return {
        isRecording: mediaRecorder && mediaRecorder.state === 'recording',
        state: mediaRecorder ? mediaRecorder.state : 'no_recorder',
        chunksCount: recordedChunks.length,
        totalSize: recordedChunks.reduce((sum, chunk) => sum + chunk.size, 0)
      };
    },

    downloadRecording: function(filename) {
      try {
        console.log('[FlutterRecording] Downloading recording...', filename);
        console.log('[FlutterRecording] Chunks available:', recordedChunks.length);

        if (recordedChunks.length === 0) {
          console.error('[FlutterRecording] No recorded chunks available');
          return false;
        }

        // Tạo blob từ chunks
        const blob = new Blob(recordedChunks, {
          type: mediaRecorder?.mimeType || 'video/webm'
        });

        console.log('[FlutterRecording] Blob created:', blob.size, 'bytes');

        if (blob.size === 0) {
          console.error('[FlutterRecording] Blob is empty');
          return false;
        }

        // Tạo URL và download
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.style.display = 'none';
        a.href = url;
        a.download = filename;

        document.body.appendChild(a);
        a.click();

        // Cleanup
        setTimeout(() => {
          document.body.removeChild(a);
          URL.revokeObjectURL(url);
        }, 100);

        console.log('[FlutterRecording] Download triggered');

        // Reset chunks sau khi download
        recordedChunks = [];

        return true;

      } catch (error) {
        console.error('[FlutterRecording] Error downloading recording:', error);
        return false;
      }
    }
  };

  console.log('[FlutterRecording] Module initialized');
})();