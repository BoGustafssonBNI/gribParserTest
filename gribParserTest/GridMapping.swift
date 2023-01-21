//
//  GridMapping.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-02-02.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//
//This program finds weights for interpolation of one 2D data field to another
//The irregular source grid is triangulated and the weights are found through barycentric coordinates
//The source grid should be simple so that each grid cell bound by (i,j),(i+1),(i+1,j+1),(i,j+1)
//can be split into two triangles given by (i,j),(i+1,j),(i,j+1) and (i+1,j),(i+1,j+1),(i,j+1)
//The destination grid can be of any shape or set of coordinates.


import Foundation

struct GridMapping {
    private var iPoints = [[Int]]()
    private var jPoints = [[Int]]()
    private var weights = [[Double]]()

    // finding points and weights

    init(xSource: [Double], ySource: [Double], imaxSource: Int, jmaxSource: Int, xDest: [Double], yDest: [Double], imaxDest: Int, jmaxDest: Int) {
        for j in 0..<jmaxDest {
            for i in 0..<imaxDest {
                let indexDest = j * imaxDest + i
                for jS in 0..<jmaxSource-1 {
                    for iS in 0..<imaxSource-1 {
                        let indexSource = jS * imaxSource + iS
                        let xT = [xSource[indexSource], xSource[indexSource + 1], xSource[indexSource + imaxSource]]
                        let yT = [ySource[indexSource], ySource[indexSource + 1], ySource[indexSource + imaxSource]]
                        if let w = getWeights(xDest[indexDest], yDest[indexDest], xT, yT) {
                            self.iPoints.append([iS, iS + 1, iS])
                            self.jPoints.append([jS, jS, jS + 1])
                            self.weights.append(w)
                        } else {
                            let xT = [xSource[indexSource + 1], xSource[indexSource + 1 + imaxSource], xSource[indexSource + imaxSource]]
                            let yT = [ySource[indexSource + 1], ySource[indexSource + 1 + imaxSource], ySource[indexSource + imaxSource]]
                            if let w = getWeights(xDest[indexDest], yDest[indexDest], xT, yT) {
                                self.iPoints.append([iS + 1, iS + 1, iS])
                                self.jPoints.append([jS, jS + 1, jS + 1])
                                self.weights.append(w)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func getWeights(_ pX: Double, _ pY: Double, _ x: [Double], _ y: [Double]) -> [Double]? {
        let w1 = ((y[1]-y[2])*(pX-x[2])+(x[2]-x[1])*(pY-y[2]))/((y[1]-y[2])*(x[0]-x[2])+(x[2]-x[1])*(y[0]-y[2]))
        if w1 < 0.0 {return nil}
        let w2 = ((y[2]-y[0])*(pX-x[2])+(x[0]-x[2])*(pY-y[2]))/((y[1]-y[2])*(x[0]-x[2])+(x[2]-x[1])*(y[0]-y[2]))
        if w2 < 0.0 {return nil}
        let w3 = 1.0-w1-w2
        if w3 < 0.0 {return nil}
        return [w1, w2, w3]
    }

}
