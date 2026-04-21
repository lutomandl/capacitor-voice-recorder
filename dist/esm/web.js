import { WebPlugin } from '@capacitor/core';
import { VoiceRecorderImpl } from './VoiceRecorderImpl';
export class VoiceRecorderWeb extends WebPlugin {
    constructor() {
        super();
        this.voiceRecorderInstance = new VoiceRecorderImpl();
        // Forward chunk events emitted by the impl to Capacitor listeners.
        this.voiceRecorderInstance.setChunkEmitter((chunk) => {
            this.notifyListeners('audioChunk', chunk);
        });
    }
    canDeviceVoiceRecord() {
        return VoiceRecorderImpl.canDeviceVoiceRecord();
    }
    hasAudioRecordingPermission() {
        return VoiceRecorderImpl.hasAudioRecordingPermission();
    }
    requestAudioRecordingPermission() {
        return VoiceRecorderImpl.requestAudioRecordingPermission();
    }
    startRecording(options) {
        return this.voiceRecorderInstance.startRecording(options);
    }
    stopRecording() {
        return this.voiceRecorderInstance.stopRecording();
    }
    pauseRecording() {
        return this.voiceRecorderInstance.pauseRecording();
    }
    resumeRecording() {
        return this.voiceRecorderInstance.resumeRecording();
    }
    getCurrentStatus() {
        return this.voiceRecorderInstance.getCurrentStatus();
    }
    startChunkedRecording(options) {
        return this.voiceRecorderInstance.startChunkedRecording(options);
    }
    stopChunkedRecording() {
        return this.voiceRecorderInstance.stopChunkedRecording();
    }
    pauseChunkedRecording() {
        return this.voiceRecorderInstance.pauseChunkedRecording();
    }
    resumeChunkedRecording() {
        return this.voiceRecorderInstance.resumeChunkedRecording();
    }
}
//# sourceMappingURL=web.js.map