//
//  DoorsView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

class DoorsViewController: UIHostingController<DoorsView> {
    var selectedRecord: Record? {
        get { record }
        set(newValue) {
            record = newValue
            setupTitleView()
            rootView = DoorsView(record: newValue)
        }
    }
    private var record: Record?

    init() {
        let doorsView = DoorsView()
        super.init(rootView: doorsView)

        configureNavigationBar()
        setupTitleView()
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var titleView = UIStackView()
    private var titleTagView = TagView()
    private var titleLabel = UILabel()
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
            let color = UIColor(record.typeColor)

            titleTagView.text = record.abbreviatedType
            titleTagView.backgroundColor = color.withAlphaComponent(0.15)
            titleTagView.foregroundColor = color

            titleTagView
                .widthAnchor
                .constraint(equalToConstant: 65)
                .isActive = true

            titleView.addArrangedSubview(titleTagView)
            titleView.setCustomSpacing(10, after: titleTagView)
        }
    }

    private func setupTitleLabel() {
        if let record = record {
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
                ToolbarItem {
                    GridLayoutButton(selectedGridLayout: $selectedGridLayout)
                }
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

    private var inPortrait: Bool {
        horizontalSize == .compact && verticalSize == .regular
    }
    private var isGrid: Bool { selectedGridLayout == .grid }

    private let sectionHeaders: [(String, String, String)] = [
        ("Not-at-Homes", "house.fill", "NotAtHomeColor"),
        ("Busy", "megaphone.fill", "BusyColor"),
        ("Call Again", "person.fill.checkmark", "CallAgainColor"),
        ("Not Interested", "person.fill.xmark", "NotInterestedColor"),
        ("Other", "dot.squareshape.fill", "OtherColor")
    ]

    private var gridColumns: [GridItem] {
        let gridColumnItem = GridItem(
            .flexible(),
            spacing: 8,
            alignment: .top
        )

        let portraitColumns = [gridColumnItem, gridColumnItem]
        let landscapeColumns = [
            gridColumnItem,
            gridColumnItem,
            gridColumnItem
        ]

        let gridColumns = inPortrait ? portraitColumns : landscapeColumns
        let listColumns = [gridColumnItem]

        return isGrid ? gridColumns : listColumns
    }
}

#if DEBUG
struct DoorsViewController_Preview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let record = Record(
            context: PersistenceController.preview.container.viewContext
        )
        record.streetName = "Street Name"
        record.city = "City"
        record.state = "State"

        let doorsViewController = DoorsViewController()
        doorsViewController.selectedRecord = record

        let navigationController = UINavigationController(
            rootViewController: doorsViewController
        )
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
