//
//  HTMLHelper.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 15/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import UIKit

class HTMLHelper {
    
    static var shared: HTMLHelper = {
        return HTMLHelper()
    }()
    
    func getHtmlFor(post: MADPost) -> String? {
        guard let postHtml = post.htmlContent else { return nil }
        let html = getOpeningHTML() + postHtml.replacingOccurrences(of: freeAppText, with: "") + getClosingHTML()
        return html
    }
    
    private func getOpeningHTML() -> String {
        return """
        <!DOCTYPE html>
        <html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://ogp.me/ns/fb#" lang="nl">
        
        <head profile="http://gmpg.org/xfn/11">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, shrink-to-fit=no">
        <title>MADPAC</title>
        <style type="text/css" media="screen">
        @import url(https://fonts.googleapis.com/css?family=Lato:300,400,700,900);
        
        /*! normalize.scss v0.1.0 | MIT License | based on git.io/normalize */
        html {
        font-family: sans-serif;
        -ms-text-size-adjust: 100%;
        -webkit-text-size-adjust: 100%
        }
        
        a, abbr, acronym, address, applet, article, aside, audio, b, big, blockquote, body, canvas, caption, center, cite, code, dd, del, details, dfn, div, dl, dt, em, embed, fieldset, figcaption, figure, footer, form, h1, h2, h3, h4, h5, h6, header, hgroup, html, i, iframe, img, ins, kbd, label, legend, li, mark, menu, nav, object, ol, output, p, pre, q, ruby, s, samp, section, small, span, strike, strong, sub, summary, sup, table, tbody, td, tfoot, th, thead, time, tr, tt, u, ul, var, video {
        border: 0;
        font: inherit;
        font-size: 100%;
        max-width: \(UIScreen.main.bounds.width - 24.0)px !important;
        margin: 0;
        padding: 0;
        vertical-align: baseline;
        }
        
        .content-layout{
        margin-top: 20px;
        margin-left: 15px;
        margin-right: 15px;
        margin-bottom: 20px;
        }
        
        .content-layout strong {
        display: block;
        font-weight: 400;
        margin-top: 20px;
        margin-bottom: 20px;
        font-style: bold;
        }
        
        .content-layout em {
        font-style: italic;
        }
        
        .content-layout a {
        color: \(UIColor.MAD.HTMLElements.hotLink);
        font-weight: 700;
        text-decoration: none;
        }
        
        body {
        width: 100vw;
        max-width: 100vw !important;
        overflow-x: hidden;
        font-family: Lato, Helvetica, sans-serif;
        font-size: 130%;
        font-weight: 200;
        color: \(UIColor.MAD.HTMLElements.primaryText);
        background-color: transparent;
        }
        
        h1 {
        font-weight: 700;
        font-size: 150%;
        margin-bottom: 15px;
        margin-top: 20px;
        }
        
        h2 {
        font-weight: 300;
        font-size: 66%;
        color: \(UIColor.MAD.HTMLElements.secondaryText);
        }
        
        h3, h4, h5, h6 {
        margin-top: 0px;
        font-weight: 300;
        font-size: 66%;
        color: \(UIColor.MAD.HTMLElements.tertiaryText);
        }
        
        p {
        font-size: 1rem;
        line-height: 1.4rem;
        line-height: 1.5em
        margin-top: 100px;
        }
        
        img {
        text-align: center;
        height: auto;
        position: relative;
        margin-top: 10px;
        width: 100%;
        }
        
        </style>
        
        <body>
        <div class="content-layout">
        """
    }
    
    private func getClosingHTML() -> String {
        return "</div></body></html>"
    }
    
    private let freeAppText: String = """
    <p><strong><em><a href="https://itunes.apple.com/nl/app/madpac/id897490802?mt=8" target="_blank" rel="noopener">Download hier de gratis </a></em><a href="https://itunes.apple.com/nl/app/madpac/id897490802?mt=8" target="_blank" rel="noopener">MADPAC</a><em><a href="https://itunes.apple.com/nl/app/madpac/id897490802?mt=8" target="_blank" rel="noopener"> app voor</a></em> <em><a href="https://itunes.apple.com/nl/app/madpac/id897490802?mt=8" target="_blank" rel="noopener">i</a><a href="https://itunes.apple.com/nl/app/madpac/id897490802?mt=8" target="_blank" rel="noopener">Phone en iPad!!</a></em></strong></p>
    """
}
