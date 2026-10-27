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

    static func sideWidth(toast: Bool) -> CGFloat { toast ? 150 : 64 }

    var body: some View {
        HStack(spacing: 0) {
            left
                .frame(width: Self.sideWidth(toast: toaster.current != nil), alignment: .leading)
            Spacer(minLength: vm.deviceNotchRect.width)
            right
                .frame(width: Self.sideWidth(toast: toaster.current != nil), alignment: .trailing)
        }
        .padding(.horizontal, 10)
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
        } else if spotify.playing {
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
}

extension NotchViewModel {
    var hasLiveActivity: Bool {
        Toaster.shared.current != nil || FocusTimer.shared.running || Spotify.shared.playing
    }
}
