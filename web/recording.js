(function() {
  let mediaRecorder = null;
  let recordedChunks = [];

  window.FlutterRecording = {
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
        };

        // Handle error
        mediaRecorder.onerror = function(event) {
          console.error('[FlutterRecording] MediaRecorder error:', event.error);
        };

        // Start recording (lưu mỗi 1 giây)
        mediaRecorder.start(1000);
        console.log('[FlutterRecording] MediaRecorder started');

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
            resolve(true);
          };
          mediaRecorder.stop();
        } else {
          resolve(false);
        }
      });
    },

    downloadRecording: function(filename) {
      try {
        console.log('[FlutterRecording] Downloading recording...', filename);

        if (recordedChunks.length === 0) {
          console.error('[FlutterRecording] No recorded chunks available');
          return false;
        }

        // Tạo blob từ chunks
        const blob = new Blob(recordedChunks, {
          type: mediaRecorder?.mimeType || 'video/webm'
        });

        console.log('[FlutterRecording] Blob created:', blob.size, 'bytes');

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