//
//  QueContentSelectModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/13.
//

import UIKit

class QueContentSelectModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentSelectCell.self
    }
    
    var contentInset: UIEdgeInsets = .zero
    
    let queLevel2: QueLevel2
    
    var fillBlankAttrStrArr: [NSMutableAttributedString]
    
    var allAttrStrArr: [NSMutableAttributedString]
    
    var resultAttributed: NSMutableAttributedString
    
    let paragraphStyle: NSParagraphStyle
    
    // 选项
    let options: [String]
    
    var focunsIndex: Int? {
        didSet {
            if let focunsIndex = oldValue, focunsIndex < fillBlankAttrStrArr.count {
                fillBlankAttrStrArr[focunsIndex].addAttribute(.underlineColor, value: UIColor.black, range: .init(location: 0, length: fillBlankAttrStrArr[focunsIndex].length))
            }
            if let focunsIndex = focunsIndex, focunsIndex < fillBlankAttrStrArr.count  {
                fillBlankAttrStrArr[focunsIndex].addAttribute(.underlineColor, value: UIColor.blue, range: .init(location: 0, length: fillBlankAttrStrArr[focunsIndex].length))
            }
            makeResultAttr()
        }
    }
    
    init?(queLevel2: QueLevel2) {
        guard queLevel2.type == .Select, let options = queLevel2.options else {
            return nil
        }
        self.queLevel2 = queLevel2
        let originContent = HTMLTranslate.stripBlk(html: queLevel2?.content ?? "")
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        style.paragraphSpacing = 10
        
        self.paragraphStyle = style
        self.options = options
        self.allAttrStrArr = []
        self.fillBlankAttrStrArr = []
        self.resultAttributed = NSMutableAttributedString()
        super.init()
        
        let comStrArr = originContent.components(separatedBy: "___")
        for (index, itemStr) in comStrArr.enumerated() {
            if !allAttrStrArr.isEmpty {
                let fillBlankIndex = index - 1
                var enterStr = spaceStr
                var haveAnswer = false
                var answer: String?
                if fillBlankIndex < (qst.userAnswers.count ?? 0) {
                    answer = qst.userAnswers[fillBlankIndex]
                }
                if let answer = answer, !answer.isEmpty {
                    enterStr = (enterStr as NSString).replacingCharacters(in: .init(location: 1, length: 1), with: answer)
                    haveAnswer = true
                }

                let fillBlankAttrStr: NSMutableAttributedString!
                if haveAnswer {
                    fillBlankAttrStr = NSMutableAttributedString(string: enterStr, attributes: [
                        .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
                        .underlineColor : UIColor.black,
                        .link : "\(snFillBlankURLPrefix)\(snSeparate)\(fillBlankIndex)",
                        .font : UIFont.systemFont(ofSize: 18),
                        .foregroundColor : UIColor.clear,
                        .paragraphStyle : paragraphStyle,
                    ])
                    fillBlankAttrStr.addAttribute(.foregroundColor, value: UIColor.blue, range: .init(location: 1, length: 1))
                } else {
                    fillBlankAttrStr = emptyFillBlankAttrStr(index: fillBlankIndex)
                }
                fillBlankAttrStrArr.append(fillBlankAttrStr)
                allAttrStrArr.append(fillBlankAttrStr)
            }
            allAttrStrArr.append(.init(string: itemStr, attributes: [
                .font : UIFont.systemFont(ofSize: 18),
                .foregroundColor : UIColor.black,
                .paragraphStyle : style
            ]))
        }
        for itemAttrStr in allAttrStrArr {
            resultAttributed.append(itemAttrStr)
        }
        resultAttributed.addAttribute(.baselineOffset, value: NSNumber(value: 5), range: .init(location: 0, length: resultAttributed.length))
    }
    
    func setAnswer(optionIndex: Int, index: Int) {
        while let count1 = qst.userAnswers.count, let count2 = qst.correctAnswers.count, count1 < count2 {
            qst.userAnswers.append("")
        }
        qst.userAnswers[index] = Tool.positionToLetter(position: optionIndex)
        
        fillBlankAttrStrArr[index].replaceCharacters(in: .init(location: 1, length: 1), with: Constant.positionToLetter(position: optionIndex))
        fillBlankAttrStrArr[index].addAttribute(.foregroundColor, value: UIColor.blue, range: .init(location: 1, length: 1))
        makeResultAttr()
    }
    
    func getAnswer(index: Int) -> Int? {
        if let str = getStrAnswer(index: index) {
            return Tool.letterToPosition(letter: str)
        } else {
            return nil
        }
    }
    
    func getStrAnswer(index: Int) -> String? {
        if index >= queLevel2.userAnswers.count {
            return nil
        }
        if let str = queLevel2.userAnswers[index] {
            return str
        } else {
            return nil
        }
    }
    
    func emptyFillBlankAttrStr(index: Int) -> NSMutableAttributedString {
        // 只能逐个添加，使用 addAttribute 添加附件没有效果
        let ret = NSMutableAttributedString()
        ret.append(.init(string: "⌘"))
        
        let attachment = NSTextAttachment(image: .init(named: "blank_icon_edit")!)
        attachment.bounds = .init(x: 0, y: 0, width: 18, height: 18)
        ret.append(.init(attachment: attachment))
        
        ret.append(.init(string: "⌘"))
        
        ret.addAttributes([
            .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
            .underlineColor : UIColor.black,
            .link : "\(snFillBlankURLPrefix)\(snSeparate)\(index)",
            .font : UIFont.systemFont(ofSize: 18),
            .foregroundColor : UIColor.clear,
            .paragraphStyle : paragraphStyle,
        ], range: .init(location: 0, length: ret.length))
        return ret
    }
    
    func makeResultAttr() {
        let resultAttributed = NSMutableAttributedString()
        for itemAttrStr in allAttrStrArr {
            resultAttributed.append(itemAttrStr)
        }
        resultAttributed.addAttribute(.baselineOffset, value: NSNumber(value: 5), range: .init(location: 0, length: resultAttributed.length))
        self.resultAttributed = resultAttributed
    }
}