import { WebPlugin } from '@capacitor/core';
import type { ChunkedRecordingOptions, CurrentRecordingStatus, GenericResponse, RecordingData, RecordingOptions, VoiceRecorderPlugin } from './definitions';
export declare class VoiceRecorderWeb extends WebPlugin implements VoiceRecorderPlugin {
    private voiceRecorderInstance;
    constructor();
    canDeviceVoiceRecord(): Promise<GenericResponse>;
    hasAudioRecordingPermission(): Promise<GenericResponse>;
    requestAudioRecordingPermission(): Promise<GenericResponse>;
    startRecording(options?: RecordingOptions): Promise<GenericResponse>;
    stopRecording(): Promise<RecordingData>;
    pauseRecording(): Promise<GenericResponse>;
    resumeRecording(): Promise<GenericResponse>;
    getCurrentStatus(): Promise<CurrentRecordingStatus>;
    startChunkedRecording(options?: ChunkedRecordingOptions): Promise<GenericResponse>;
    stopChunkedRecording(): Promise<GenericResponse>;
    pauseChunkedRecording(): Promise<GenericResponse>;
    resumeChunkedRecording(): Promise<GenericResponse>;
}
