//
//  DSDSExpandableHasTagLabel.swift
//  DSDSExpandableHasTagLabel
//
//  Created by Shiyani on 04/05/24.
//

import UIKit

typealias LineIndexTuple = (line: CTLine, index: Int)

import UIKit

/**
 * The delegate of DSExpandableHasTagLabel.
 */
@objc public protocol DSExpandableHasTagLabelDelegate: NSObjectProtocol {
    @objc func willExpandLabel(_ label: DSExpandableHasTagLabel)
    @objc func didExpandLabel(_ label: DSExpandableHasTagLabel)
    @objc func willCollapseLabel(_ label: DSExpandableHasTagLabel)
    @objc func didCollapseLabel(_ label: DSExpandableHasTagLabel)
}

/**
 * DSExpandableHasTagLabel
 */
@objc open class DSExpandableHasTagLabel: UILabel {
    public enum TextReplacementType {
        case character
        case word
    }

    /// The delegate of DSExpandableHasTagLabel
    @objc weak open var delegate: DSExpandableHasTagLabelDelegate?

    /// Set 'true' if the label should be collapsed or 'false' for expanded.
    @IBInspectable open var collapsed: Bool = true {
        didSet {
            super.attributedText = (collapsed) ? self.collapsedText : self.expandedText
            super.numberOfLines = (collapsed) ? self.collapsedNumberOfLines : 0
            if let animationView = animationView {
                UIView.animate(withDuration: 0.5) {
                    animationView.layoutIfNeeded()
                }
            }
        }
    }

    /// Set 'true' if the label can be expanded or 'false' if not.
    /// The default value is 'true'.
    @IBInspectable open var shouldExpand: Bool = true

    /// Set 'true' if the label can be collapsed or 'false' if not.
    /// The default value is 'false'.
    @IBInspectable open var shouldCollapse: Bool = false

    /// Set the link name (and attributes) that is shown when collapsed.
    /// The default value is "More". Cannot be nil.
    @objc open var collapsedAttributedLink: NSAttributedString! {
        didSet {
            self.collapsedAttributedLink = collapsedAttributedLink.copyWithAddedFontAttribute(font)
        }
    }

    /// Set the link name (and attributes) that is shown when expanded.
    /// The default value is "Less". Can be nil.
    @objc open var expandedAttributedLink: NSAttributedString?

    /// Set the ellipsis that appears just after the text and before the link.
    /// The default value is "...". Can be nil.
    @objc open var ellipsis: NSAttributedString? {
        didSet {
            self.ellipsis = ellipsis?.copyWithAddedFontAttribute(font)
        }
    }

    /// Set a view to animate changes of the label collapsed state with. If this value is nil, no animation occurs.
    /// Usually you assign the superview of this label or a UIScrollView in which this label sits.
    /// Also don't forget to set the contentMode of this label to top to smoothly reveal the hidden lines.
    /// The default value is 'nil'.
    @objc open var animationView: UIView?

    open var textReplacementType: TextReplacementType = .word

    private var collapsedText: NSAttributedString?
    private var linkHighlighted: Bool = false
    private let touchSize = CGSize(width: 44, height: 44)
    private var linkRect: CGRect?
    private var collapsedNumberOfLines: NSInteger = 0
    private var expandedLinkPosition: NSTextAlignment?
    private var collapsedLinkTextRange: NSRange?
    private var expandedLinkTextRange: NSRange?
    var arrHashTag = [String]()
    open var onHashtagTapped:((String)->())?
    var arrMentionUser = [String]()
    open var onTagUserTapped:((String)->())?
    
    open override var numberOfLines: NSInteger {
        didSet {
            collapsedNumberOfLines = numberOfLines
        }
    }

    @objc public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    @objc public init() {
        super.init(frame: .zero)
    }

    open override var text: String? {
        set(text) {
            if let text = text {
                self.attributedText = NSAttributedString(string: text)
            } else {
                self.attributedText = nil
            }
            self.arrHashTag = findHashTagText(text: text ?? "")
            self.arrMentionUser = findMentionUserText(text: text ?? "")
        }
        get {
            return self.attributedText?.string
        }
    }
    

    open private(set) var expandedText: NSAttributedString?
    open override var attributedText: NSAttributedString? {
        set(attributedText) {
            if let attributedText = attributedText?.copyWithAddedFontAttribute(font).copyWithParagraphAttribute(font),
                attributedText.length > 0 {
                self.collapsedText = getCollapsedText(for: attributedText, link: (linkHighlighted) ? collapsedAttributedLink.copyWithHighlightedColor() : self.collapsedAttributedLink)
                self.expandedText = getExpandedText(for: attributedText, link: (linkHighlighted) ? expandedAttributedLink?.copyWithHighlightedColor() : self.expandedAttributedLink)
                super.attributedText = (self.collapsed) ? self.collapsedText : self.expandedText
            } else {
                self.expandedText = nil
                self.collapsedText = nil
                super.attributedText = nil
            }
        }
        get {
            return super.attributedText
        }
    }

    open func setLessLinkWith(lessLink: String, attributes: [NSAttributedString.Key: AnyObject], position: NSTextAlignment?) {
        var alignedattributes = attributes
        if let pos = position {
            expandedLinkPosition = pos
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = pos
            alignedattributes[.paragraphStyle] = titleParagraphStyle
        }
        expandedAttributedLink = NSMutableAttributedString(string: lessLink,
                                                           attributes: alignedattributes)
    }
}

// MARK: - Touch Handling
extension DSExpandableHasTagLabel {

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        setLinkHighlighted(touches, event: event, highlighted: true)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        setLinkHighlighted(touches, event: event, highlighted: false)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        if !collapsed {
            guard let range = self.expandedLinkTextRange else {
                return
            }

            if shouldCollapse && check(touch: touch, isInRange: range) {
                delegate?.willCollapseLabel(self)
                collapsed = true
                delegate?.didCollapseLabel(self)
                linkHighlighted = isHighlighted
                setNeedsDisplay()
            }
        } else {
            if shouldExpand && setLinkHighlighted(touches, event: event, highlighted: false) {
                delegate?.willExpandLabel(self)
                collapsed = false
                delegate?.didExpandLabel(self)
            }
        }
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        setLinkHighlighted(touches, event: event, highlighted: false)
    }
}

// MARK: Privates
extension DSExpandableHasTagLabel {
    private func commonInit() {
        isUserInteractionEnabled = true
        lineBreakMode = .byClipping
        collapsedNumberOfLines = numberOfLines
        expandedAttributedLink = nil
        collapsedAttributedLink = NSAttributedString(string: "More", attributes: [.font: UIFont.boldSystemFont(ofSize: font.pointSize)])
        ellipsis = NSAttributedString(string: "...")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }

    private func textReplaceWordWithLink(_ lineIndex: LineIndexTuple, text: NSAttributedString, linkName: NSAttributedString) -> NSAttributedString {
        let lineText = text.text(for: lineIndex.line)
        var lineTextWithLink = lineText
        (lineText.string as NSString).enumerateSubstrings(in: NSRange(location: 0, length: lineText.length), options: [.byWords, .reverse]) { (word, subRange, enclosingRange, stop) -> Void in
            let lineTextWithLastWordRemoved = lineText.attributedSubstring(from: NSRange(location: 0, length: subRange.location))
            let lineTextWithAddedLink = NSMutableAttributedString(attributedString: lineTextWithLastWordRemoved)
            if let ellipsis = self.ellipsis {
                lineTextWithAddedLink.append(ellipsis)
                lineTextWithAddedLink.append(NSAttributedString(string: " ", attributes: [.font: self.font ?? UIFont.systemFont(ofSize: 12)]))
            }
            lineTextWithAddedLink.append(linkName)
            let fits = self.textFitsWidth(lineTextWithAddedLink)
            if fits {
                lineTextWithLink = lineTextWithAddedLink
                let lineTextWithLastWordRemovedRect = lineTextWithLastWordRemoved.boundingRect(for: self.frame.size.width)
                let wordRect = linkName.boundingRect(for: self.frame.size.width)
                let width = lineTextWithLastWordRemoved.string == "" ? self.frame.width : wordRect.size.width
                self.linkRect = CGRect(x: lineTextWithLastWordRemovedRect.size.width, y: self.font.lineHeight * CGFloat(lineIndex.index), width: width, height: wordRect.size.height)
                stop.pointee = true
            }
        }
        return lineTextWithLink
    }

    private func textReplaceWithLink(_ lineIndex: LineIndexTuple, text: NSAttributedString, linkName: NSAttributedString) -> NSAttributedString {
        let lineText = text.text(for: lineIndex.line)
        let lineTextTrimmedNewLines = NSMutableAttributedString()
        lineTextTrimmedNewLines.append(lineText)
        let nsString = lineTextTrimmedNewLines.string as NSString
        let range = nsString.rangeOfCharacter(from: CharacterSet.newlines)
        if range.length > 0 {
            lineTextTrimmedNewLines.replaceCharacters(in: range, with: "")
        }
        let linkText = NSMutableAttributedString()
        if let ellipsis = self.ellipsis {
            linkText.append(ellipsis)
            linkText.append(NSAttributedString(string: " ", attributes: [.font: self.font ?? UIFont.systemFont(ofSize: 13)]))
        }
        linkText.append(linkName)

        let lengthDifference = lineTextTrimmedNewLines.string.composedCount - linkText.string.composedCount
        let truncatedString = lineTextTrimmedNewLines.attributedSubstring(
            from: NSMakeRange(0, lengthDifference >= 0 ? lengthDifference : lineTextTrimmedNewLines.string.composedCount))
        let lineTextWithLink = NSMutableAttributedString(attributedString: truncatedString)
        lineTextWithLink.append(linkText)
        return lineTextWithLink
    }

    private func getExpandedText(for text: NSAttributedString?, link: NSAttributedString?) -> NSAttributedString? {
        guard let text = text else { return nil }
        let expandedText = NSMutableAttributedString()
        expandedText.append(text)
        if let link = link, textWillBeTruncated(expandedText) {
            let spaceOrNewLine = expandedLinkPosition == nil ? "  " : "\n"
            expandedText.append(NSAttributedString(string: "\(spaceOrNewLine)"))
            expandedText.append(NSMutableAttributedString(string: "\(link.string)", attributes: link.attributes(at: 0, effectiveRange: nil)).copyWithAddedFontAttribute(font))
            expandedLinkTextRange = NSMakeRange(expandedText.length - link.length, link.length)
        }

        return expandedText.copyWithHighlightedUsername(usernames: self.arrMentionUser)
    }

    private func getCollapsedText(for text: NSAttributedString?, link: NSAttributedString) -> NSAttributedString? {
        guard let text = text else { return nil }
        let lines = text.lines(for: frame.size.width)
        if collapsedNumberOfLines > 0 && collapsedNumberOfLines < lines.count {
            let lastLineRef = lines[collapsedNumberOfLines-1] as CTLine
            var lineIndex: LineIndexTuple?
            var modifiedLastLineText: NSAttributedString?

            if self.textReplacementType == .word {
                lineIndex = findLineWithWords(lastLine: lastLineRef, text: text, lines: lines)
                if let lineIndex = lineIndex {
                    modifiedLastLineText = textReplaceWordWithLink(lineIndex, text: text, linkName: link)
                }
            } else {
                lineIndex = (lastLineRef, collapsedNumberOfLines - 1)
                if let lineIndex = lineIndex {
                    modifiedLastLineText = textReplaceWithLink(lineIndex, text: text, linkName: link)
                }
            }

            if let lineIndex = lineIndex, let modifiedLastLineText = modifiedLastLineText {
                let collapsedLines = NSMutableAttributedString()
                for index in 0..<lineIndex.index {
                    collapsedLines.append(text.text(for:lines[index]))
                }
                collapsedLines.append(modifiedLastLineText)

                collapsedLinkTextRange = NSRange(location: collapsedLines.length - link.length, length: link.length)
                return collapsedLines
            } else {
                return nil
            }
        }
        return text.copyWithHighlightedUsername(usernames: self.arrMentionUser)
    }

    private func findLineWithWords(lastLine: CTLine, text: NSAttributedString, lines: [CTLine]) -> LineIndexTuple {
        var lastLineRef = lastLine
        var lastLineIndex = collapsedNumberOfLines - 1
        var lineWords = spiltIntoWords(str: text.text(for: lastLineRef).string as NSString)
        while lineWords.count < 2 && lastLineIndex > 0 {
            lastLineIndex -=  1
            lastLineRef = lines[lastLineIndex] as CTLine
            lineWords = spiltIntoWords(str: text.text(for: lastLineRef).string as NSString)
        }
        return (lastLineRef, lastLineIndex)
    }

    private func spiltIntoWords(str: NSString) -> [String] {
        var strings: [String] = []
        str.enumerateSubstrings(in: NSRange(location: 0, length: str.length), options: [.byWords, .reverse]) { (word, subRange, enclosingRange, stop) -> Void in
            if let unwrappedWord = word {
                strings.append(unwrappedWord)
            }
            if strings.count > 1 { stop.pointee = true }
        }
        return strings
    }

    private func textFitsWidth(_ text: NSAttributedString) -> Bool {
        return (text.boundingRect(for: frame.size.width).size.height <= font.lineHeight) as Bool
    }

    private func textWillBeTruncated(_ text: NSAttributedString) -> Bool {
        let lines = text.lines(for: frame.size.width)
        return collapsedNumberOfLines > 0 && collapsedNumberOfLines < lines.count
    }

    private func textClicked(touches: Set<UITouch>?, event: UIEvent?) -> Bool {
        let touch = event?.allTouches?.first
        let location = touch?.location(in: self)
        let textRect = self.attributedText?.boundingRect(for: self.frame.width)
        if let location = location, let textRect = textRect {
            let finger = CGRect(x: location.x-touchSize.width/2, y: location.y-touchSize.height/2, width: touchSize.width, height: touchSize.height)
            if finger.intersects(textRect) {
                return true
            }
        }
        return false
    }

    @discardableResult private func setLinkHighlighted(_ touches: Set<UITouch>?, event: UIEvent?, highlighted: Bool) -> Bool {
        guard let touch = touches?.first else {
            return false
        }

        guard let range = self.collapsedLinkTextRange else {
            return false
        }

        if collapsed && check(touch: touch, isInRange: range) {
            linkHighlighted = highlighted
            setNeedsDisplay()
            return true
        }
        return false
    }
    
    // Handle tap gesture
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        
        let location = gesture.location(in: self)
        let index = self.indexOfAttributedTextCharacterAtPoint(point: location)
        
        guard let attributedText = self.attributedText else { return }
        
        // Check if 'Read More'/'Read Less' was tapped
        let readMoreLessRange = (attributedText.string as NSString).range(of: "Read More")
        let readLessRange = (attributedText.string as NSString).range(of: "Read Less")
        
        var isHashTagFind = false
        if readMoreLessRange.contains(index) || readLessRange.contains(index) {
            // Toggle expansion
            self.numberOfLines = self.numberOfLines == 0 ? 3 : 0
        } else {
            // Check if a hashtag was tapped
            for item in self.arrHashTag {
                let wordRange = (attributedText.string as NSString).range(of: item, options: .regularExpression)
                if wordRange.contains(index) {
                    let tappedHashtag = (attributedText.string as NSString).substring(with: wordRange)
                    print(tappedHashtag)
                    isHashTagFind = true
                    onHashtagTapped?(tappedHashtag)
                }
            }
            for item in self.arrMentionUser {
                let wordRange = (attributedText.string as NSString).range(of: item, options: .regularExpression)
                if wordRange.contains(index) {
                    let tappedHashtag = (attributedText.string as NSString).substring(with: wordRange)
                    print(tappedHashtag)
                    isHashTagFind = true
                    onTagUserTapped?(tappedHashtag)
                }
            }
        }
        if isHashTagFind == false {
            if !collapsed {
                delegate?.willCollapseLabel(self)
                collapsed = true
                delegate?.didCollapseLabel(self)
                linkHighlighted = isHighlighted
                setNeedsDisplay()
            } else {
                delegate?.willExpandLabel(self)
                collapsed = false
                delegate?.didExpandLabel(self)
            }
        }
    }
    
    func didTapAttributedTextInLabelTemp(gesture: UITapGestureRecognizer, label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = gesture.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
            
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
            
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
    // Helper function to find the index of the character in the attributed text at the tap location
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: self.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
    
    private func findHashTagText(text: String) -> [String] {
        var arr_hasStrings:[String] = []
        let regex = try? NSRegularExpression(pattern: "(#[a-zA-Z0-9_\\p{Arabic}\\p{N}]*)", options: [])
        if let matches = regex?.matches(in: text, options:[], range:NSMakeRange(0, text.count)) {
            for match in matches {
                arr_hasStrings.append(NSString(string: text).substring(with: NSRange(location:match.range.location, length: match.range.length )))
            }
        }
        return arr_hasStrings
    }
    
    private func findMentionUserText(text: String) -> [String] {
        let pattern = "@(\\w+)"
        var taggedUsernames = [String]()
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
            for match in matches {
                if let range = Range(match.range, in: text) {
                    taggedUsernames.append(String(text[range]))
                }
            }
        }
        return taggedUsernames
    }
}

// MARK: Convenience Methods
private extension NSAttributedString {
    func hasFontAttribute() -> Bool {
        guard !self.string.isEmpty else { return false }
        let font = self.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        return font != nil
    }

    func copyWithParagraphAttribute(_ font: UIFont) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.05
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 0.0
        paragraphStyle.minimumLineHeight = font.lineHeight
        paragraphStyle.maximumLineHeight = font.lineHeight

        let copy = NSMutableAttributedString(attributedString: self)
        let range = NSRange(location: 0, length: copy.length)
        copy.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        copy.addAttribute(.baselineOffset, value: font.pointSize * 0.08, range: range)
        return copy
    }

    func copyWithAddedFontAttribute(_ font: UIFont) -> NSAttributedString {
        if !hasFontAttribute() {
            let copy = NSMutableAttributedString(attributedString: self)
            copy.addAttribute(.font, value: font, range: NSRange(location: 0, length: copy.length))
            return copy
        }
        return self.copy() as! NSAttributedString
    }

    func copyWithHighlightedColor() -> NSAttributedString {
        let alphaComponent = CGFloat(0.5)
        let baseColor: UIColor = (self.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor)?.withAlphaComponent(alphaComponent) ??
            UIColor.black.withAlphaComponent(alphaComponent)
        let highlightedCopy = NSMutableAttributedString(attributedString: self)
        let range = NSRange(location: 0, length: highlightedCopy.length)
        highlightedCopy.removeAttribute(.foregroundColor, range: range)
        highlightedCopy.addAttribute(.foregroundColor, value: baseColor, range: range)
        return highlightedCopy
    }

    func copyWithHighlightedUsername(usernames: [String]) -> NSAttributedString {
        let highlightedCopy = NSMutableAttributedString(attributedString: self)
        
        // Define the range of the entire string
        let fullRange = NSRange(location: 0, length: highlightedCopy.length)
        
        // Remove any existing foreground color attribute
        highlightedCopy.removeAttribute(.foregroundColor, range: fullRange)
        
        // Set the default color with reduced alpha for the entire text
        let alphaComponent = CGFloat(0.5)
        let baseColor: UIColor = UIColor.black.withAlphaComponent(alphaComponent)
        highlightedCopy.addAttribute(.foregroundColor, value: UIColor(named: "ColorTitleText") ?? .black, range: fullRange)
        
        // Find the range of the username and set the blue color
        usernames.forEach { name in
            let usernameRange = (self.string as NSString).range(of: name)
            if usernameRange.location != NSNotFound {
                highlightedCopy.addAttribute(.foregroundColor, value: UIColor.link, range: usernameRange)
            }
        }
        return highlightedCopy
    }
    
    func lines(for width: CGFloat) -> [CTLine] {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        let frameSetterRef: CTFramesetter = CTFramesetterCreateWithAttributedString(self as CFAttributedString)
        let frameRef: CTFrame = CTFramesetterCreateFrame(frameSetterRef, CFRange(location: 0, length: 0), path.cgPath, nil)

        let linesNS: NSArray  = CTFrameGetLines(frameRef)
        let linesAO: [AnyObject] = linesNS as [AnyObject]
        let lines: [CTLine] = linesAO as! [CTLine]

        return lines
    }

    func text(for lineRef: CTLine) -> NSAttributedString {
        let lineRangeRef: CFRange = CTLineGetStringRange(lineRef)
        let range: NSRange = NSRange(location: lineRangeRef.location, length: lineRangeRef.length)
        return self.attributedSubstring(from: range)
    }

    func boundingRect(for width: CGFloat) -> CGRect {
        return self.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                 options: .usesLineFragmentOrigin, context: nil)
    }
}

extension String {
    var composedCount : Int {
        var count = 0
        enumerateSubstrings(in: startIndex..<endIndex, options: .byComposedCharacterSequences) { _,_,_,_  in count += 1 }
        return count
    }
}

extension UILabel {
    public func check(touch: UITouch, isInRange targetRange: NSRange) -> Bool {
        let touchPoint = touch.location(in: self)
        let index = characterIndex(at: touchPoint)
        return NSLocationInRange(index, targetRange)
    }

    private func characterIndex(at touchPoint: CGPoint) -> Int {
        guard let attributedString = attributedText else { return NSNotFound }
        if !bounds.contains(touchPoint) {
            return NSNotFound
        }

        let textRect = self.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        if !textRect.contains(touchPoint) {
            return NSNotFound
        }

        var point = touchPoint
        // Offset tap coordinates by textRect origin to make them relative to the origin of frame
        point = CGPoint(x: point.x - textRect.origin.x, y: point.y - textRect.origin.y)
        // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
        point = CGPoint(x: point.x, y: textRect.size.height - point.y)

        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedString.length), nil, CGSize(width: textRect.width, height: CGFloat.greatestFiniteMagnitude), nil)

        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: suggestedSize.width, height: CGFloat(ceilf(Float(suggestedSize.height)))))

        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedString.length), path, nil)
        let lines = CTFrameGetLines(frame)
        let linesCount = numberOfLines > 0 ? min(numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines)
        if linesCount == 0 {
            return NSNotFound
        }

        var lineOrigins = [CGPoint](repeating: .zero, count: linesCount)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, linesCount), &lineOrigins)

        for (idx, lineOrigin) in lineOrigins.enumerated() {
            var lineOrigin = lineOrigin
            let lineIndex = CFIndex(idx)
            let line = unsafeBitCast(CFArrayGetValueAtIndex(lines, lineIndex), to: CTLine.self)

            // Get bounding information of line
            var ascent: CGFloat = 0.0
            var descent: CGFloat = 0.0
            var leading: CGFloat = 0.0
            let width = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
            let yMin = CGFloat(floor(lineOrigin.y - descent))
            let yMax = CGFloat(ceil(lineOrigin.y + ascent))

            // Apply penOffset using flushFactor for horizontal alignment to set lineOrigin since this is the horizontal offset from drawFramesetter
            let flushFactor = flushFactorForTextAlignment(textAlignment: textAlignment)
            let penOffset = CGFloat(CTLineGetPenOffsetForFlush(line, flushFactor, Double(textRect.size.width)))
            lineOrigin.x = penOffset

            // Check if we've already passed the line
            if point.y > yMax {
                return NSNotFound
            }
            // Check if the point is within this line vertically
            if point.y >= yMin {
                // Check if the point is within this line horizontally
                if point.x >= lineOrigin.x && point.x <= lineOrigin.x + width {
                    // Convert CT coordinates to line-relative coordinates
                    let relativePoint = CGPoint(x: point.x - lineOrigin.x, y: point.y - lineOrigin.y)
                    return Int(CTLineGetStringIndexForPosition(line, relativePoint))
                }
            }
        }

        return NSNotFound
    }

    private func flushFactorForTextAlignment(textAlignment: NSTextAlignment) -> CGFloat {
        switch textAlignment {
        case .center:
            return 0.5
        case .right:
            return 1.0
        case .left, .natural, .justified:
            return 0.0
        @unknown default:
            return 0.0
        }
    }
}
extension DSExpandableHasTagLabel {
    func applyColorToUserMentions(color: UIColor) {
        guard let text = self.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        let regex = try! NSRegularExpression(pattern: "\\S*@[a-zA-Z0-9_.]+\\S*", options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        for match in matches {
            attributedString.addAttribute(.foregroundColor, value: color, range: match.range)
        }
        
        self.attributedText = attributedString
    }
}

