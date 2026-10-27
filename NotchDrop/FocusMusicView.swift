//
//  FocusMusicView.swift
//  NotchKu
//

import SwiftUI

struct FocusMusicView: View {
    @StateObject var vm: NotchViewModel
    @ObservedObject var focus = FocusTimer.shared
    @ObservedObject var spotify = Spotify.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            music
            Divider().overlay(.white.opacity(0.1))
            timer
        }
        .padding(12)
        .frame(width: 210)
        .frame(maxHeight: .infinity)
        .background(.white.opacity(0.1))
        .clipShape(.rect(cornerRadius: vm.cornerRadius))
        .font(.system(.footnote, design: .rounded))
    }

    var music: some View {
        HStack(spacing: 8) {
            Group {
                if let artwork = spotify.artwork {
                    Image(nsImage: artwork).resizable()
                } else {
                    Image(systemName: "music.note")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.white.opacity(0.1))
                }
            }
            .frame(width: 36, height: 36)
            .clipShape(.rect(cornerRadius: 6))
            VStack(alignment: .leading, spacing: 2) {
                Text(spotify.title.isEmpty ? "Spotify belum diputar" : spotify.title)
                    .fontWeight(.semibold)
                Text(spotify.artist).foregroundStyle(.secondary)
            }
            .lineLimit(1)
            Spacer(minLength: 0)
        }
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 10) {
                Button { spotify.previous() } label: { Image(systemName: "backward.fill") }
                Button { spotify.playPause() } label: {
                    Image(systemName: spotify.playing ? "pause.fill" : "play.fill")
                }
                Button { spotify.next() } label: { Image(systemName: "forward.fill") }
            }
            .buttonStyle(.plain)
            .opacity(spotify.isRunning ? 1 : 0.3)
            .disabled(!spotify.isRunning)
            .offset(y: 4)
        }
    }

    var timer: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer").foregroundStyle(.orange)
            if focus.running {
                Text(focus.label)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .fontWeight(.semibold)
                Spacer()
                Button("Berhenti") { focus.stop() }
            } else {
                Text("Fokus")
                Spacer()
                ForEach([25, 50, 90], id: \.self) { minutes in
                    Button("\(minutes)m") { focus.start(minutes: minutes) }
                }
            }
        }
        .buttonStyle(.plain)
        .animation(vm.animation, value: focus.remaining)
    }
}
