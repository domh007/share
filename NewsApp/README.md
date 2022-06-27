# News App

## Notes
I used an MVVM pattern and SwiftUI to get some more practice with SwiftUI.  

The initial iteration does NOT use Combine subscribers.  This was a conscious decision to enable an illustration of the use of protocols to decouple the compnents. 

I've abstracted the HTTP service and the view model into protocols. This facilitates DI facilitating easy of testing and adding decoupled components to enable reuse and extensibilty. 

## TODO
Add unit tests for NYTNewsService

Add Combine subscription into the Service layers. 

Add section sorting for the data in the Model to enable sectioned lists in the UI.


