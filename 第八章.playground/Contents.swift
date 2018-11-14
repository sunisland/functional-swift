//: Playground - noun: a place where people can play

import UIKit

struct Trie <Element : Hashable> {
    let isElement : Bool
    let children : [Element : Trie<Element>]
}


extension Array {
    var decompose : (Element , [Element])? {
        return isEmpty ? nil : (self[startIndex], Array(self.dropFirst()))
    }
    
}

extension Trie {
    
    init(_ key : [Element]) {
        if let (head, tail) = key.decompose {
            let children = [head : Trie(tail)]
            self = Trie(isElement : false, children : children)
        }else{
            self = Trie(isElement : true, children : [:])
        }
    }
    
    var elements : [[Element]] {
        var result : [[Element]] = isElement ? [[]] : []
        for (key, value) in children{
            result += value.elements.map {[key] + $0}
        }
        return result
    }
    
    
    func lookup (key : [Element]) -> Bool {
        
        guard let (head, tail) = key.decompose else {
            return isElement
        }
        guard  let subtrie = children[head] else {
            return false
        }
        return subtrie.lookup(key: tail)
    }
    
    func insert (key : [Element]) -> Trie{
        guard let (head, tail) = key.decompose else {
            return Trie(isElement : true, children : children)
        }
        var newChildren = children
        if let nextTrie = children[head] {
            newChildren[head] = nextTrie.insert(key: tail)
        }else{
            newChildren[head] = Trie(tail)
        }
        return Trie(isElement : isElement, children : newChildren)
    }
    
    func withPrefix(prefix : [Element]) -> Trie<Element>? {
        
        guard let (head, tail) = prefix.decompose else {
            // 如果不能再分割, 找到了包含prefix的子树,
            return self
        }
        guard let remainter = children[head] else {
            // 没找到完全匹配的prefix
            return nil
        }
        // 递归调用
        return remainter.withPrefix(prefix: tail)
        
    }
    
    func autocomplete(key : [Element]) -> [[Element]] {
        // 找到匹配的然后读取 匹配的子树, 不包含已经匹配的部分, 读取的是, 匹配的子树剩余的部分
        // 如果没有找到, 就返回空数组
        return withPrefix(prefix: key)?.elements ?? []
    }
    
    
}

func buildStringTrie(words : [String]) -> Trie<Character>{
    let emptyTrie = Trie<Character>(isElement: false, children: [:])
    return words.reduce(emptyTrie, { (trie, word)  in
        trie.insert(key: Array(word))
    })
}


func autoCompleteString (knowWords : Trie<Character>, word : String) -> [String] {
    let chars = Array(word)
    let completed = knowWords.autocomplete(key: chars)
    return completed.map{chars in
        word + chars
    }
}



let contents = ["cat", "car", "cart", "dog"]
let trieOfWord = buildStringTrie(words: contents)
let result = autoCompleteString(knowWords: trieOfWord, word: "car")
print("result \(result)")



