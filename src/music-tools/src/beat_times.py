import librosa

folder = "/mnt/storage1/Music/UNSORTED/"


def get_bpm(audio_file):
    """Gets the BPM of a song.

    Args:
      audio_file: The path to the audio file.

    Returns:
      The BPM of the song.
    """

    # filename = "example.wav"
    # y, sr = librosa.load(filename)
    # tempo, beat_frames = librosa.beat.beat_track(y=y, sr=sr)
    # print(beat_times)
    # librosa.output.times_csv("beat_times.csv", beat)

    tempo = 0

    try:
        y, sr = librosa.load(audio_file)
        tempo, beat_frames = librosa.beat.beat_track(y=y, sr=sr)
        # print ("Beat Frames: {}".format(beat_frames))
        print("Beat Frame count: {}".format(len(beat_frames)))
    except Exception as e:
        print(e)
    return tempo


if __name__ == "__main__":

    audio_file = "Erik_B_and_Rakim-Follow_the_leader_.mp3"
    bpm = get_bpm(folder + audio_file)
    print("The BPM of the song is:", bpm)
