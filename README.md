# Swux

Swux is an experiment to use a [flux-like](https://facebook.github.io/flux/) architecture in Swift.

## Usage

### The store
```swift
// Holds the state for the feed
class FeedStore : FluxStore {
    
    private let feedService = FeedService()
    private var feed: [FeedItem] = []
    
    override init() {
        super.init()
        
        // Register for dispatcher updates
        self.dispatchId = Dispatcher.sharedInstance.register { (action) in            
            switch action {                
            case .RefreshFeed: self.refresh()                
            case .ClearFeed: self.clear()
            default: break;
            }
        }
    }
    
    // The only public API
    func getFeed() -> [FeedItem] {        
        return self.feed
    }

    private func clear() {
      self.feed = []
      self.emit(.Updated)
    }
    
    private func refresh() {
        let userId = 1234

        feedService.loadFeedForUser(userId).onSuccess { items in
          self.feed = items
          self.emit(.Updated)
        }.onFailure { error in
          self.clear()
        }
    }
}
```

### The view controller
```swift
class FeedController : BaseController {
        
    // UI
    @IBOutlet var collectionView: UICollectionView!
    
    // Services
    let feedStore = FeedStore()
    
    // State
    var listenerId: Int?
    var feed: [FeedItem] = []

    override func viewDidLoad() {
      super.viewDidLoad()

      // Listen to changes in the store
      self.listenerId = self.feedStore.addListener({ [unowned self] _ in
            
            // Get the new state
            self.feed = self.feedStore.getFeed()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Trigger a re-render of the collection view (the feed)
                self.collectionView.reloadData()
            })
        })

        Dispatcher.sharedInstance.dispatch(.RefreshFeed)
    }

    // ... do a lot more with the collection view
    
}
```
