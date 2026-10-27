//
//  LiveActivityView.swift
//  NotchKu
//

import SwiftUI

// isi kiri dan kanan notch saat tertutup: kabar singkat, timer fokus, atau lagu Spotify
struct LiveActivityView: View {
    @StateObject var vm: NotchViewModel
    @ObservedObject var toaster = Toaster.shared
    @ObservedObject var focus = FocusTimer.shared
    @ObservedObject var spotify = Spotify.shared

    static func sideWidth(toast: Bool, song: Bool = false) -> CGFloat {
        toast ? 150 : song ? 110 : 64
    }

    static let songHeight: CGFloat = 46

    var sideWidth: CGFloat {
        Self.sideWidth(toast: toaster.current != nil, song: spotify.announcing)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                left
                    .frame(width: sideWidth, alignment: .leading)
                Spacer(minLength: vm.deviceNotchRect.width)
                right
                    .frame(width: sideWidth, alignment: .trailing)
            }
            .padding(.horizontal, 10)
            .frame(maxHeight: .infinity)
            if spotify.announcing {
                song
                    .frame(height: Self.songHeight)
                    .transition(.modifier(
                        active: IslandContent(progress: 0),
                        identity: IslandContent(progress: 1)
                    ))
            }
        }
        .font(.system(size: 12, weight: .semibold, design: .rounded))
        .foregroundStyle(.white)
        .lineLimit(1)
        .transition(.opacity)
    }

    @ViewBuilder var left: some View {
        if let toast = toaster.current {
            Image(systemName: toast.icon)
        } else if focus.running {
            Image(systemName: "timer").foregroundStyle(.orange)
        } else if spotify.playing, !spotify.announcing {
            if let artwork = spotify.artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .frame(width: 18, height: 18)
                    .clipShape(.rect(cornerRadius: 4))
            } else {
                Image(systemName: "music.note").foregroundStyle(.green)
            }
        }
    }

    @ViewBuilder var right: some View {
        if let toast = toaster.current {
            Text(toast.text)
        } else if focus.running {
            Text(focus.label)
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(.orange)
        } else if spotify.playing {
            Image(systemName: "waveform")
                .symbolEffect(.variableColor.iterative)
                .foregroundStyle(.green)
        }
    }

    var song: some View {
        HStack(spacing: 10) {
            Group {
                if let artwork = spotify.artwork {
                    Image(nsImage: artwork).resizable()
                } else {
                    Image(systemName: "music.note")
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.white.opacity(0.1))
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(.rect(cornerRadius: 6))
            VStack(alignment: .leading, spacing: 1) {
                Text(spotify.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                Text(spotify.artist)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .truncationMode(.tail)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

extension NotchViewModel {
    var hasLiveActivity: Bool {
        Toaster.shared.current != nil || FocusTimer.shared.running || Spotify.shared.playing
    }
}
