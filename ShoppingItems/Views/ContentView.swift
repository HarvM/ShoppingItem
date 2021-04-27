//
//  ContentView.swift
//  ShoppingItems
//
//  Created by Marc Harvey on 05/01/2020.
//  Copyright © 2020 Marc Harvey. All rights reserved.
//
import SwiftUI
import Foundation

///Images used across the ContentView
enum ContentViewImages: String {
    case plusImage = "plusIcon" ///On the textEntry field and will let the user add an item
}

struct ContentView: View {
    
    //MARK: - Properties
    @State var isEditing = false
    @ObservedObject var listStore: ShoppingItemStore
    let generator = UINotificationFeedbackGenerator()
    @Environment (\.managedObjectContext) var managedObjectContext
    @Environment (\.presentationMode) var presentationMode
    @Environment (\.colorScheme) var colorScheme
    @FetchRequest(entity: ShoppingItems.entity(), sortDescriptors:
                    [NSSortDescriptor (keyPath: \ShoppingItems.order, ascending: true)])
    var shoppingItemEntries: FetchedResults<ShoppingItems>
    
    //MARK: Main body of the view
    var body: some View {
        listView
    }
    
    ///Use of ViewBuilder to differentiate between the populated and unpopulated list
    ///Using this to display the placeholder screen
    @ViewBuilder
    var listView: some View {
        ///If no shoppingItemEntries on the list then display the placeholder image
        if shoppingItemEntries.count == 0 {
            emptyListView
        } else {
            populatedView
        }
    }
    
    var emptyListView: some View {
        ZStack {
            Color("defaultBackground")
                .edgesIgnoringSafeArea(.all)
            NavigationView {
                Image("appHeader")
                .background(Color("defaultBackground").edgesIgnoringSafeArea(.all))
                .navigationBarItems(leading: EditButton()
                .simultaneousGesture(TapGesture()
                .onEnded {
                    isEditing = false }),
                    trailing: NavigationLink(destination: NewEntryView()
                    .navigationBarTitle("Add Item")
                    .frame(minWidth: 0, idealWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: 0, maxHeight: .infinity, alignment:.center)
                    .edgesIgnoringSafeArea(.all) ){
                                        ///Image of the trailing icon tha leads the user to the map
                                        Image(ContentViewImages.plusImage.rawValue)
                                            .frame(width: 35, height: 35)
                                            .cornerRadius(38.5)
                                            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
                                    })
                .foregroundColor(.white)
                .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
                .background(Color("defaultBackground")
                                .edgesIgnoringSafeArea(.all))
            }
            .background(Color("defaultBackground")
                            .edgesIgnoringSafeArea(.all))
        }
        .background(Color("defaultBackground")
                        .edgesIgnoringSafeArea(.all))
    }
    
    //MARK: - emptyListView
    ///Will be displayed when the user hasn't entered any items onto the shopping list/no items on the model
//    var emptyListView: some View {
//        ZStack {
//            Color("defaultBackground")
//                .edgesIgnoringSafeArea(.all)
//            NavigationView {
//                ///Placeholder image
//                Image("appHeader")
//                .background(Color("defaultBackground").edgesIgnoringSafeArea(.all))
//                .navigationBarItems(leading: EditButton()
//                .simultaneousGesture(TapGesture()
//                .onEnded {
//                    isEditing = false }),
//                    trailing: NavigationLink(destination: NewEntryView()
//                    .navigationBarTitle("Add Item")
//                    .frame(minWidth: 0, idealWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: 0, maxHeight: .infinity, alignment:.center)
//                    .edgesIgnoringSafeArea(.all)
//                                ){
//                                    ///Image of the trailing icon tha leads the user to the map
//                                    Image(ContentViewImages.plusImage.rawValue)
//                                        .frame(width: 35, height: 35)
//                                        .cornerRadius(38.5)
//                                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
//                                        .background(Color("defaultBackground").edgesIgnoringSafeArea(.all))
//                                })
//            .foregroundColor(.white)
//            .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
//            .background(Color("defaultBackground")
//                            .edgesIgnoringSafeArea(.all))
//        }
//        .background(Color("defaultBackground")
//                        .edgesIgnoringSafeArea(.all))
//        }
//        .background(Color("defaultBackground")
//                        .edgesIgnoringSafeArea(.all))
//    }
    
    var populatedView: some View {
        ZStack {
            Color("defaultBackground")
                .edgesIgnoringSafeArea(.all)
            NavigationView {
                List {
                    //MARK: - HStack: how the cells are displayed and populated
                    Section() {
                        ForEach(shoppingItemEntries, id: \.self) {
                            shoppingItemNew in
                            HStack {
                                CellView(itemToBeAdded: shoppingItemNew.itemToBeAdded, quantitySelected: shoppingItemNew.quantitySelected,
                                         preferredMeasurement: shoppingItemNew.preferredMeasurement)
                                NavigationLink("", destination: DetailView (itemToBeDisplayed: shoppingItemNew))
                            }
                        }
                        .onDelete(perform: self.deleteItem)
                        .onMove(perform: moveItem)
                    }
                    .listStyle(PlainListStyle())
                    .listRowBackground(Color("defaultBackground")
                                        .edgesIgnoringSafeArea(.all))
                    
                    //NEW BUTTON!
//
//                    VStack(alignment: .trailing, spacing: 10) {
//                        Button("Do Something"){
//
//                        }
//                        .background(Color("defaultBackground").edgesIgnoringSafeArea(.all))
//                        .padding(.bottom, 20)
//                    }
//                    .background(Color("defaultBackground").edgesIgnoringSafeArea(.all))
                }
                ///Appears to help with the reordering of the List and makes it less laggy when a row is moved
                .id(UUID())
                ///Removes the header and the wee arrow that hides/shows the cells
                .listStyle(PlainListStyle())
                ///Ensures that the list is closer to the top of the window
                .navigationBarTitleDisplayMode(.inline)
    
                //MARK: - NavigationBarItems: Leading item will be the EditButton that lets the user edit the list, the trailing launches MapView
                .navigationBarItems(leading: EditButton()
                                        .simultaneousGesture(TapGesture()
                                        .onEnded {
                                            isEditing = false
                                        }),
                                    trailing: NavigationLink(destination: NewEntryView()
                                                                .navigationBarTitle("Add Item")
                                                                .frame(minWidth: 0, idealWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: 0, maxHeight: .infinity, alignment:.center)
                                                                .edgesIgnoringSafeArea(.all)
                                    ){
                                        ///Image of the trailing icon tha leads the user to the map
                                        Image(ContentViewImages.plusImage.rawValue)
                                            .frame(width: 35, height: 35)
                                            .cornerRadius(38.5)
                                            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
                                    })
                .foregroundColor(.white)
                .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
                .background(Color("defaultBackground")
                                .edgesIgnoringSafeArea(.all))
                
            }
            .background(Color("defaultBackground")
                            .edgesIgnoringSafeArea(.all)
            )
        }
        .background(Color("defaultBackground")
                        .edgesIgnoringSafeArea(.all)
        )
    }
    
    init() {
        ///Below is various attempts at getting the from from the Picker to display a different background colour
        UIListContentView.appearance().backgroundColor = UIColor(Color("defaultBackground"))
        UIPickerView.appearance().backgroundColor = UIColor(Color("defaultBackground"))
        UIPickerView.appearance().tintColor = UIColor(Color("defaultBackground"))
        ///Setting the empty/potential cells to the desired colour
        UITableView.appearance().backgroundColor = UIColor(Color("defaultBackground"))
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default) ///clears navBar to background colour
        UINavigationBar.appearance().shadowImage = UIImage() ///removes seperator
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().backgroundColor = UIColor(Color("defaultBackground"))
        ///Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        ///Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        ///Have to init the listStore with a value
        self.listStore = ShoppingItemStore.init()

    }
    }
//
//    //MARK: - Body of the view
//    var body: some View {
//        ZStack {
//            Color("defaultBackground")
//                .edgesIgnoringSafeArea(.all)
//            NavigationView {
//                List {
//                    //MARK: - HStack: how the cells are displayed and populated
//                    Section() {
//                        ForEach(shoppingItemEntries, id: \.self) {
//                            shoppingItemNew in
//                            HStack {
//                                CellView(itemToBeAdded: shoppingItemNew.itemToBeAdded, quantitySelected: shoppingItemNew.quantitySelected,
//                                         preferredMeasurement: shoppingItemNew.preferredMeasurement)
//                                NavigationLink("", destination: DetailView (itemToBeDisplayed: shoppingItemNew))
//                            }
//                        }
//                        .onDelete(perform: self.deleteItem)
//                        .onMove(perform: moveItem)
//                    }
//                    .listStyle(PlainListStyle())
//                    .listRowBackground(Color("defaultBackground")
//                                        .edgesIgnoringSafeArea(.all))
//
//                    //NEW BUTTON!
////
////                    VStack(alignment: .trailing, spacing: 10) {
////                        Button("Do Something"){
////
////                        }
////                        .background(Color("defaultBackground").edgesIgnoringSafeArea(.all))
////                        .padding(.bottom, 20)
////                    }
////                    .background(Color("defaultBackground").edgesIgnoringSafeArea(.all))
//                }
//                ///Appears to help with the reordering of the List and makes it less laggy when a row is moved
//                .id(UUID())
//                ///Removes the header and the wee arrow that hides/shows the cells
//                .listStyle(PlainListStyle())
//                ///Ensures that the list is closer to the top of the window
//                .navigationBarTitleDisplayMode(.inline)
//
//                //MARK: - NavigationBarItems: Leading item will be the EditButton that lets the user edit the list, the trailing launches MapView
//                .navigationBarItems(leading: EditButton()
//                                        .simultaneousGesture(TapGesture()
//                                        .onEnded {
//                                            isEditing = false
//                                        }),
//                                    trailing: NavigationLink(destination: NewEntryView()
//                                                                .navigationBarTitle("Add Item")
//                                                                .frame(minWidth: 0, idealWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: 0, maxHeight: .infinity, alignment:.center)
//                                                                .edgesIgnoringSafeArea(.all)
//                                    ){
//                                        ///Image of the trailing icon tha leads the user to the map
//                                        Image(ContentViewImages.plusImage.rawValue)
//                                            .frame(width: 35, height: 35)
//                                            .cornerRadius(38.5)
//                                            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
//                                    })
//                .foregroundColor(.white)
//                .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
//                .background(Color("defaultBackground")
//                                .edgesIgnoringSafeArea(.all))
//
//            }
//            .background(Color("defaultBackground")
//                            .edgesIgnoringSafeArea(.all)
//            )
//        }
//        .background(Color("defaultBackground")
//                        .edgesIgnoringSafeArea(.all)
//        )
//    }
//
//    init() {
//        ///Below is various attempts at getting the from from the Picker to display a different background colour
//        UIListContentView.appearance().backgroundColor = UIColor(Color("defaultBackground"))
//        UIPickerView.appearance().backgroundColor = UIColor(Color("defaultBackground"))
//        UIPickerView.appearance().tintColor = UIColor(Color("defaultBackground"))
//        ///Setting the empty/potential cells to the desired colour
//        UITableView.appearance().backgroundColor = UIColor(Color("defaultBackground"))
//        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default) ///clears navBar to background colour
//        UINavigationBar.appearance().shadowImage = UIImage() ///removes seperator
//        UINavigationBar.appearance().isTranslucent = true
//        UINavigationBar.appearance().backgroundColor = UIColor(Color("defaultBackground"))
//        ///Use this if NavigationBarTitle is with Large Font
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//        ///Use this if NavigationBarTitle is with displayMode = .inline
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
//        ///Have to init the listStore with a value
//        self.listStore = ShoppingItemStore.init()
//
//    }
//}
//
//struct KeyboardAvoiderDemo: View {
//    @State var text = ""
//    var body: some View {
//        VStack {
//            TextField("Demo", text: self.$text)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .contentShape(Rectangle())
//        .onTapGesture {}
//        .onLongPressGesture(
//            pressing: { isPressed in if isPressed { self.endEditing() } },
//            perform: {})
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
