final public class Page {
    enum Status {
        case empty
        case changed
        case saved
    }
    
    public var content = "" { didSet { status = .changed } }
    private(set) var status = Status.empty
    
    init() { }
}
