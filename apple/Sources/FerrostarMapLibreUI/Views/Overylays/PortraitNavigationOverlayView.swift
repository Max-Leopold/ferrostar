import FerrostarCore
import FerrostarSwiftUI
import MapKit
import MapLibre
import MapLibreSwiftDSL
import MapLibreSwiftUI
import SwiftUI

struct PortraitNavigationOverlayView: View, CustomizableNavigatingInnerGridView {
    @Environment(\.navigationFormatterCollection) var formatterCollection: any FormatterCollection

    private var navigationState: NavigationState?

    var topCenter: (() -> AnyView)?
    var topTrailing: (() -> AnyView)?
    var midLeading: (() -> AnyView)?
    var bottomTrailing: (() -> AnyView)?

    var speedLimit: Measurement<UnitSpeed>?
    var showZoom: Bool
    var onZoomIn: () -> Void
    var onZoomOut: () -> Void
    var showCentering: Bool
    var onCenter: () -> Void
    var onTapExit: (() -> Void)?

    init(
        navigationState: NavigationState?,
        speedLimit: Measurement<UnitSpeed>? = nil,
        showZoom: Bool = false,
        onZoomIn: @escaping () -> Void = {},
        onZoomOut: @escaping () -> Void = {},
        showCentering: Bool = false,
        onCenter: @escaping () -> Void = {},
        onTapExit: (() -> Void)? = nil
    ) {
        self.navigationState = navigationState
        self.speedLimit = speedLimit
        self.showZoom = showZoom
        self.onZoomIn = onZoomIn
        self.onZoomOut = onZoomOut
        self.showCentering = showCentering
        self.onCenter = onCenter
        self.onTapExit = onTapExit
    }

    var body: some View {
        VStack {
            if let navigationState,
               let visualInstructions = navigationState.visualInstruction
            {
                InstructionsView(
                    visualInstruction: visualInstructions,
                    distanceFormatter: formatterCollection.distanceFormatter,
                    distanceToNextManeuver: navigationState.progress?.distanceToNextManeuver
                )
                .padding(.horizontal, 16)
            }

            // The inner content is displayed vertically full screen
            // when both the visualInstructions and progress are nil.
            // It will automatically reduce height if and when either
            // view appears
            // TODO: Add dynamic speed, zoom & centering.
            NavigatingInnerGridView(
                speedLimit: speedLimit,
                showZoom: showZoom,
                onZoomIn: onZoomIn,
                onZoomOut: onZoomOut,
                showCentering: showCentering,
                onCenter: onCenter
            )
            .innerGrid {
                topCenter?()
            } topTrailing: {
                topTrailing?()
            } midLeading: {
                midLeading?()
            } bottomTrailing: {
                bottomTrailing?()
            }
            .padding(.horizontal, 16)

            if let progress = navigationState?.progress {
                ArrivalView(
                    progress: progress,
                    onTapExit: onTapExit
                )
                .padding(.horizontal, 16)
            }
        }
    }
}
