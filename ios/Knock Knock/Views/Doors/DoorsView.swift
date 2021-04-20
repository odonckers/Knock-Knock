//
//  DoorsView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

class DoorsViewController: UIHostingController<AnyView> {
    var selectedRecord: Record? {
        get { record }
        set(newValue) {
            record = newValue
            setupTitleView()

            let doorsView = DoorsView(record: newValue)
                .environment(\.uiNavigationController, navigationController)
            rootView = AnyView(doorsView)
        }
    }
    private var record: Record?

    init() {
        super.init(rootView: AnyView(EmptyView()))

        let doorsView = DoorsView()
            .environment(\.uiNavigationController, navigationController)
        rootView = AnyView(doorsView)

        configureNavigationBar()
        setupTitleView()
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var titleView = UIStackView()
}

extension DoorsViewController {
    private func configureNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
    }
}

extension DoorsViewController {
    private func setupTitleView() {
        navigationItem.titleView = titleView

        titleView.axis = .horizontal
        titleView.alignment = .center

        setupTitleTag()
        setupTitleLabel()
    }

    private func setupTitleTag() {
        if let record = record {
            let hostingController = UIHostingController(
                rootView: Tag(
                    text: record.abbreviatedType,
                    backgroundColor: record.typeColor
                )
                .foregroundColor(record.typeColor)
            )
            guard let titleTagView = hostingController.view else { return }
            titleTagView.backgroundColor = .clear

            titleView.addArrangedSubview(titleTagView)
        }
    }

    private func setupTitleLabel() {
        if let record = record {
            let titleLabel = UILabel()
            titleLabel.text = record.wrappedStreetName
            titleLabel.font =  UIFont.preferredFont(forTextStyle: .headline)
            titleLabel.adjustsFontForContentSizeCategory = true

            titleView.addArrangedSubview(titleLabel)
        }
    }
}

struct DoorsView: View {
    var record: Record? = nil

    var body: some View {
        if record != nil {
            ScrollView {
                LazyVGrid(columns: gridColumns) {
                    ForEach(sectionHeaders, id: \.0) { header in
                        let groupLabel = Label(header.0, systemImage: header.1)
                            .foregroundColor(Color(header.2))

                        GroupBox(label: groupLabel) {
                            ForEach(0..<header.0.count) { index in
                                Text("Index \(index)")
                            }
                        }
                        .groupBoxStyle(CardGroupBoxStyle())
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem { GridLayoutButton(selectedGridLayout: $selectedGridLayout) }
            }
            .filledBackground(Color.groupedBackground)
        } else {
            VStack(alignment: .center) {
                Text("Select a Record")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
    }

    @Environment(\.horizontalSizeClass)
    private var horizontalSize

    @Environment(\.verticalSizeClass)
    private var verticalSize

    // MARK: - Grid

    @State private var selectedGridLayout: GridLayoutOptions = .grid

    private var inPortrait: Bool { horizontalSize == .compact && verticalSize == .regular }
    private var isGrid: Bool { selectedGridLayout == .grid }

    private let sectionHeaders: [(String, String, String)] = [
        ("Not-at-Homes", "house.fill", "NotAtHomeColor"),
        ("Busy", "megaphone.fill", "BusyColor"),
        ("Call Again", "person.fill.checkmark", "CallAgainColor"),
        ("Not Interested", "person.fill.xmark", "NotInterestedColor"),
        ("Other", "dot.squareshape.fill", "OtherColor")
    ]

    private var gridColumns: [GridItem] {
        let gridColumnItem = GridItem(.flexible(), spacing: 8, alignment: .top)

        let portraitColumns = [gridColumnItem, gridColumnItem]
        let landscapeColumns = [gridColumnItem, gridColumnItem, gridColumnItem]

        let gridColumns = inPortrait ? portraitColumns : landscapeColumns
        let listColumns = [gridColumnItem]

        return isGrid ? gridColumns : listColumns
    }
}

#if DEBUG
struct DoorsViewController_Preview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let record = Record(context: PersistenceController.preview.container.viewContext)
        record.streetName = "Street Name"
        record.city = "City"
        record.state = "State"

        let doorsViewController = DoorsViewController()
        doorsViewController.selectedRecord = record

        let navigationController = UINavigationController(rootViewController: doorsViewController)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) { }
}

struct DoorsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DoorsViewController_Preview()
        }
    }
}
#endif
