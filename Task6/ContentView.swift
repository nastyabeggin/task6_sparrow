import SwiftUI

struct DiagonalStack: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        subviews.reduce(CGSize.zero) { result, subview in
            let size = subview.sizeThatFits(.unspecified)
            return CGSize(
                width: proposal.width ?? 0,
                height: result.height + size.height)
        }
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var point = bounds.origin
        var xPosition = bounds.maxX - subviews[0].dimensions(in: .unspecified).width
        let step = abs(bounds.minX - xPosition) / Double(subviews.count - 1)
        
        for subview in subviews.reversed() {
            point.x = xPosition
            subview.place(at: point, anchor: .zero, proposal: .unspecified)
            xPosition -= step
            point.y += subview.dimensions(in: .unspecified).height
        }
    }
}

struct ContentView: View {
    @State private var isDiagonal = false
    let numberOfSquares: CGFloat = 7
    let stackSpacing: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            let layout = isDiagonal ? AnyLayout(DiagonalStack()) : AnyLayout(HStackLayout(spacing: stackSpacing))
            let squareSize: CGFloat = isDiagonal ? 
            geometry.size.height / numberOfSquares :
            (geometry.size.width - stackSpacing * (numberOfSquares - 1)) / numberOfSquares
            layout {
                ForEach(0..<Int(self.numberOfSquares), id: \.self) { index in
                    Rectangle()
                        .fill(Color.blue)
                        .clipShape(.rect(cornerRadius: 10))
                        .frame(
                            width: squareSize,
                            height: squareSize)
                        .animation(.smooth, value: self.isDiagonal)
                }
            }
            .onTapGesture {
                withAnimation {
                    self.isDiagonal.toggle()
                }
            }
            .frame(height: geometry.size.height)
        }
    }
}


#Preview {
    ContentView()
}
