//
//  LanguageRecognizer.swift
//  MultiLanguageGlossary
//
//  Created by Artem Misesin on 4/15/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import Foundation

class Translator {
    
    static let apiKey = "AIzaSyAie4YCtNVZCcD1hKvp3qAG-cp3W9rjTu8"
    
    enum RequestBuilder {
        case detect(word: String)
        case translate(word: String, source: String?, target: String)
        
        private var service: String {
            switch self {
            case .detect:
                return "/detect"
            case .translate:
                return ""
            }
        }
        
        private var baseURL: String {
            var text: String
            switch self {
            case .detect(let word):
                text = word
            case .translate(let word, _, _):
                text = word
            }
            guard let urlEncodedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                preconditionFailure("Unknown error")
            }
            return "https://translation.googleapis.com/language/translate/v2\(self.service)?key=\(Translator.apiKey)&q=\(urlEncodedText)"
        }
        
        var url: URL? {
            switch self {
            case .detect:
                return URL(string: baseURL)
            case .translate(_, let source, let target):
                var newLink: String
                if let source = source {
                    newLink = baseURL + "&source=\(source)&target=\(target)&format=text"
                } else {
                    newLink = baseURL + "&target=\(target)&format=text"
                }
                return URL(string: newLink)
            }
        }
    }
    
    private func detectLanguage(fromText text: String, callback: @escaping (LanguageDetection?, Error?) -> Void) {
        let builder = RequestBuilder.detect(word: text)
        if let url = builder.url {
            let request = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard
                    error == nil,
                    let httpURLResponse = response as? HTTPURLResponse,
                    httpURLResponse.statusCode == 200,
                    let data = data
                else {
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(LanguageDetection.self, from: data)
                    callback(result, nil)
                } catch {
                    preconditionFailure("JSON mapper is invalid")
                }
            }
            request.resume()
        }
    }
    
    func translate(_ text: String, source language: String?, callback: @escaping (TranslationResult?, Error?) -> Void) {
        let builder = RequestBuilder.translate(word: text, source: language, target: "en")
        if let url = builder.url {
            let request = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard
                    error == nil,
                    let httpURLResponse = response as? HTTPURLResponse,
                    httpURLResponse.statusCode == 200,
                    let data = data
                    else {
                        print(response)
                        callback(nil, error)
                        return
                }
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(TranslationResult.self, from: data)
                    callback(result, nil)
                } catch {
                    preconditionFailure("JSON mapper is invalid")
                }
            }
            request.resume()
        }
    }
    
}
