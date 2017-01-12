/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
import Foundation
import VisualRecognitionV3

class VisualRecognitionTests: XCTestCase {
    
    private var visualRecognition: VisualRecognition!
    private let classifierName = "swift-sdk-unit-test-cars-trucks"
    private let collectionName = "swift-sdk-unit-test-faces"
    private var classifierID: String?
    private var collectionID: String?
    private var imageFaceID: String?
    private let timeout: TimeInterval = 10.0
    private let timeoutLong: TimeInterval = 45.0
    
    static var allTests : [(String, (VisualRecognitionTests) -> () throws -> Void)] {
        return [
            ("testGetClassifiers", testGetClassifiers),
            ("testCreateDeleteClassifier1", testCreateDeleteClassifier1),
            ("testCreateDeleteClassifier2", testCreateDeleteClassifier2),
            ("testGetClassifier", testGetClassifier),
            ("testUpdateClassifier", testUpdateClassifier),
            ("testUpdateClassifierWithPositiveExample", testUpdateClassifierWithPositiveExample),
            ("testUpdateClassifierWithNegativeExample", testUpdateClassifierWithNegativeExample),
            ("testClassifyByURL1", testClassifyByURL1),
            ("testClassifyByURL2", testClassifyByURL2),
            ("testClassifyByURL3", testClassifyByURL3),
            ("testClassifyByURL4", testClassifyByURL4),
            ("testClassifyByURL5", testClassifyByURL5),
            ("testClassifyImage1", testClassifyImage1),
            ("testClassifyImage2", testClassifyImage2),
            ("testClassifyImage3", testClassifyImage3),
            ("testClassifyImage4", testClassifyImage4),
            ("testClassifyImage5", testClassifyImage5),
            ("testClassifyImage6", testClassifyImage6),
            ("testDetectFacesByURL", testDetectFacesByURL),
            ("testDetectFacesByImage1", testDetectFacesByImage1),
            ("testDetectFacesByImage2", testDetectFacesByImage2),
            ("testGetCollections", testGetCollections),
            ("testRetrieveCollectionDetails", testRetrieveCollectionDetails),
            ("testAddDeleteImageToCollection", testAddDeleteImageToCollection),
            ("testAddDeleteImageWithMetadataToCollection", testAddDeleteImageWithMetadataToCollection),
            ("testCreateDeleteCollection", testCreateDeleteCollection),
            ("testListImagesInCollection", testListImagesInCollection),
            ("testSimilarImages", testSimilarImages),
            ("testNegativeSimilarImages", testNegativeSimilarImages),
        ]
    }
    
    private var examplesBaseball: URL!
    private var examplesCars: URL!
    private var examplesTrucks: URL!
    private var faces: URL!
    private var face1: URL!
    private var car: URL!
    private var obama: URL!
    private var sign: URL!
    
    private let obamaURL = "https://www.whitehouse.gov/sites/whitehouse.gov/files/images/" +
                           "Administration/People/president_official_portrait_lores.jpg"
    private let carURL = "https://raw.githubusercontent.com/watson-developer-cloud/" +
                         "java-sdk/master/tests/src/test/resources/visual_recognition/car.png"
    private let signURL = "https://raw.githubusercontent.com/watson-developer-cloud/java-sdk/" +
                          "master/tests/src/test/resources/visual_recognition/open.png"
    
    // MARK: - Test Configuration
    
    /** Set up for each test by instantiating the service. */
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        instantiateVisualRecognition()
        loadImageFiles()
        lookupClassifier()
        lookupCollection()
    }
    
    /** Instantiate Visual Recognition. */
    func instantiateVisualRecognition() {
        let apiKey = Credentials.VisualRecognitionAPIKey
        let version = "2016-11-04"
        visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
    }
    
    /** Load image files with class examples and test images. */
    func loadImageFiles() {
        let bundle = Bundle(for: type(of: self))
        guard
            let examplesBaseball = bundle.url(forResource: "baseball", withExtension: "zip"),
            let examplesCars = bundle.url(forResource: "cars", withExtension: "zip"),
            let examplesTrucks = bundle.url(forResource: "trucks", withExtension: "zip"),
            let faces = bundle.url(forResource: "faces", withExtension: "zip"),
            let face1 = bundle.url(forResource: "face1", withExtension: "jpg"),
            let car = bundle.url(forResource: "car", withExtension: "png"),
            let obama = bundle.url(forResource: "obama", withExtension: "jpg"),
            let sign = bundle.url(forResource: "sign", withExtension: "jpg")
        else {
            XCTFail("Unable to locate sample image files.")
            return
        }
        
        self.examplesBaseball = examplesBaseball
        self.examplesCars = examplesCars
        self.examplesTrucks = examplesTrucks
        self.faces = faces
        self.face1 = face1
        self.car = car
        self.obama = obama
        self.sign = sign
    }
    
    /** Look up (or create) the trained classifier. */
    func lookupClassifier() {
        let description = "Look up (or create) the trained classifier."
        let expectation = self.expectation(description: description)
        
        let failure = { (error: Error) in
            XCTFail("Failed to locate the trained classifier.")
        }
        
        visualRecognition.getClassifiers(failure: failure) { classifiers in
            for classifier in classifiers {
                if classifier.name == self.classifierName {
                    XCTAssert(classifier.status == "ready", "Wait for training to complete.")
                    self.classifierID = classifier.classifierID
                    expectation.fulfill()
                    return
                }
            }
            expectation.fulfill()
        }
        waitForExpectations()
        
        if (classifierID == nil) {
            trainClassifier()
        }
    }
    
    /** Look up (or create) the collection. */
    func lookupCollection() {
        let description = "Look up (or create) the collection."
        let expectation = self.expectation(description: description)
        
        let failure = { (error: Error) in
            XCTFail("Failed to locate the collection.")
        }
        
        visualRecognition.getCollections(failure: failure) { collections in
            for collection in collections {
                if collection.name == self.collectionName {
                    XCTAssert(collection.status == "available", "Wait for collection to be made.")
                    self.collectionID = collection.collectionID
                    expectation.fulfill()
                    return
                }
            }
            expectation.fulfill()
        }
        waitForExpectations()
        
        if (collectionID == nil) {
            createCollectionWithFaceImages()
        }
    }
    
    /** Train a classifier for the test suite. */
    func trainClassifier() {
        let description = "Train a classifier for the test suite."
        let expectation = self.expectation(description: description)
        
        let car = PositiveExample(name: "car", examples: examplesCars)
        let failure = { (error: Error) in XCTFail("Could not train classifier for test suite.") }
        visualRecognition.createClassifier(
            withName: classifierName,
            positiveExamples: [car],
            negativeExamples: examplesTrucks,
            failure: failure) { classifier in
                self.classifierID = classifier.classifierID
                expectation.fulfill()
        }
        waitForExpectations()
        
        XCTFail("Training a classifier for the test suite. Try again in 10 seconds.")
    }
    
    /** Create a collection for the test suite. */
    func createCollectionWithFaceImages() {
        let description = "Create a collection for the test suite."
        let expectation = self.expectation(description: description)
        
        let failure = { (error: Error) in XCTFail("Could not create a collection for test suite.") }
        visualRecognition.createCollection(
            withName: collectionName,
            failure: failure) { collection in
                self.collectionID = collection.collectionID
                expectation.fulfill()
        }
        waitForExpectations()
        
        let description2 = "Add first image to collection."
        let expectation2 = self.expectation(description: description2)
        let failure2 = { (error: Error) in XCTFail("Could not add face1.jpg to collection.") }
        
        guard let collection = collectionID else {
            return
        }
        visualRecognition.addImageToCollection(withID: collection, imageFile: face1, failure: failure2) { images in
            self.imageFaceID = images.collectionImages[0].imageID
            expectation2.fulfill()
        }
        waitForExpectations()
        
        let description3 = "Add second image to collection."
        let expectation3 = self.expectation(description: description3)
        let failure3 = { (error: Error) in XCTFail("Could not add sign.jpg to collection.") }
        
        visualRecognition.addImageToCollection(withID: collection, imageFile: sign, failure: failure3) { images in
            expectation3.fulfill()
        }
        waitForExpectations()
    }
    
    /** Load file used when adding metadata to an image. */
    func loadMetadataFile(withName name: String, withExtension: String) -> URL? {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: name, withExtension: withExtension) else {
            return nil
        }
        return url
    }

    /** Fail false negatives. */
    func failWithError(error: Error) {
        XCTFail("Positive test failed with error: \(error)")
    }
    
    /** Fail false positives. */
    func failWithResult<T>(result: T) {
        XCTFail("Negative test returned a result.")
    }
    
    /** Wait for expectations. */
    func waitForExpectations() {
        waitForExpectations(timeout: timeout) { error in
            XCTAssertNil(error, "Timeout")
        }
    }
    
    // MARK: - Positive Tests
    
    /** Retrieve a list of user-trained classifiers. */
    func testGetClassifiers() {
        let description = "Retrieve a list of user-trained classifiers."
        let expectation = self.expectation(description: description)
        
        visualRecognition.getClassifiers(failure: failWithError) { classifiers in
            for classifier in classifiers {
                let idMatch = (classifier.classifierID == self.classifierID)
                let nameMatch = (classifier.name == self.classifierName)
                if idMatch && nameMatch {
                    expectation.fulfill()
                    return
                }
            }
            XCTFail("Could not retrieve the trained classifier.")
        }
        waitForExpectations()
    }
    
    /** Train a classifier with only positive examples. */
    func testCreateDeleteClassifier1() {
        let description1 = "Train a classifier with only positive examples."
        let expectation1 = expectation(description: description1)
        
        let name = "swift-sdk-unit-test-1"
        let baseball = PositiveExample(name: "baseball", examples: examplesBaseball)
        let cars = PositiveExample(name: "car", examples: examplesCars)
        let trucks = PositiveExample(name: "truck", examples: examplesTrucks)
        let classes = [baseball, cars, trucks]
        
        var classifierID: String?
        visualRecognition.createClassifier(withName: name, positiveExamples: classes, failure: failWithError) {
            classifier in
            XCTAssertEqual(classifier.name, name)
            XCTAssertEqual(classifier.classes.count, 3)
            classifierID = classifier.classifierID
            expectation1.fulfill()
        }
        waitForExpectations()
        
        let description2 = "Check that our classifier can be retrieved."
        let expectation2 = expectation(description: description2)
        
        guard let classifierIDToDelete = classifierID else {
            return
        }
        
        visualRecognition.getClassifiers(failure: failWithError) { classifiers in
            for classifier in classifiers {
                if classifier.classifierID == classifierIDToDelete {
                    expectation2.fulfill()
                    return
                }
            }
            XCTFail("The created classifier could not be retrieved from the service.")
        }
        waitForExpectations()
        
        let description3 = "Delete the custom classifier."
        let expectation3 = expectation(description: description3)
        
        visualRecognition.deleteClassifier(withID: classifierIDToDelete, failure: failWithError) {
            expectation3.fulfill()
        }
        waitForExpectations()
    }
    
    /** Train a classifier with both positive and negative examples. */
    func testCreateDeleteClassifier2() {
        let description1 = "Train a classifier with both positive and negative examples."
        let expectation1 = expectation(description: description1)
        
        let name = "swift-sdk-unit-test-2"
        let cars = PositiveExample(name: "car", examples: examplesCars)
        
        var classifierID: String?
        visualRecognition.createClassifier(
            withName: name,
            positiveExamples: [cars],
            negativeExamples: examplesTrucks,
            failure: failWithError) { classifier in
                XCTAssertEqual(classifier.name, name)
                XCTAssertEqual(classifier.classes.count, 1)
                classifierID = classifier.classifierID
                expectation1.fulfill()
        }
        waitForExpectations()
        
        guard let newClassifierID = classifierID else {
            XCTFail("Failed to create a new classifier due to free account.")
            return
        }
        
        let description2 = "Check that our classifier can be retrieved."
        let expectation2 = expectation(description: description2)
        
        visualRecognition.getClassifiers(failure: failWithError) { classifiers in
            for classifier in classifiers {
                if classifier.classifierID == newClassifierID {
                    expectation2.fulfill()
                    return
                }
            }
            XCTFail("The created classifier could not be retrieved from the service.")
        }
        waitForExpectations()
        
        let description3 = "Delete the custom classifier."
        let expectation3 = expectation(description: description3)

        visualRecognition.deleteClassifier(withID: newClassifierID, failure: failWithError) {
            expectation3.fulfill()
        }
        waitForExpectations()
    }
    
    /** Get information about the trained classifier. */
    func testGetClassifier() {
        let description = "Get information about the trained classifier."
        let expectation = self.expectation(description: description)

        visualRecognition.getClassifier(withID: classifierID!, failure: failWithError) {
            classifier in
            XCTAssertEqual(classifier.name, self.classifierName)
            XCTAssertEqual(classifier.classes.count, 1)
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Update the trained classifier. */
    func testUpdateClassifier() {
        let description = "Update the trained classifier."
        let expectation = self.expectation(description: description)
        
        let car = PositiveExample(name: "car", examples: examplesCars)
        visualRecognition.updateClassifier(
            withID: classifierID!,
            positiveExamples: [car],
            negativeExamples: examplesTrucks,
            failure: failWithError) { classifier in
                XCTAssertEqual(classifier.name, self.classifierName)
                expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Update the classifier with a positive example. */
    func testUpdateClassifierWithPositiveExample() {
        let description1 = "Train a new classifier with positive examples."
        let expectation1 = expectation(description: description1)
        
        let name = "swift-sdk-unit-test-positive-update"
        let cars = PositiveExample(name: "car", examples: examplesCars)
        let trucks = PositiveExample(name: "truck", examples: examplesTrucks)
        
        var classifierID: String?
        visualRecognition.createClassifier(
            withName: name,
            positiveExamples: [cars],
            negativeExamples: examplesBaseball,
            failure: failWithError) { classifier in
                XCTAssertEqual(classifier.name, name)
                XCTAssertEqual(classifier.classes.count, 1)
                classifierID = classifier.classifierID
                expectation1.fulfill()
        }
        waitForExpectations()
        
        guard let newClassifierID = classifierID else {
            XCTFail("Failed to create a new classifier due to free account.")
            return
        }
        var trained = false
        var tries = 0
        while(!trained) {
            tries += 1
            let description = "Get the new classifier."
            let expectation = self.expectation(description: description)
            visualRecognition.getClassifier(withID: newClassifierID, failure: failWithError) {
                classifier in
                
                if classifier.status == "ready" {
                    trained = true
                }
                expectation.fulfill()
            }
            waitForExpectations()
            
            if tries > 5 {
                let description = "Delete the new classifier."
                let expectation = self.expectation(description: description)
                
                visualRecognition.deleteClassifier(withID: newClassifierID, failure: failWithError) {
                    expectation.fulfill()
                }
                waitForExpectations()
                
                XCTFail("Could not train a new classifier. Try again later.")
            }
            
            sleep(5)
        }
        
        let description2 = "Update the classifier with a positive example."
        let expectation2 = expectation(description: description2)
        
        visualRecognition.updateClassifier(
            withID: newClassifierID,
            positiveExamples: [trucks],
            failure: failWithError) { classifier in
                XCTAssertEqual(classifier.name, name)
                expectation2.fulfill()
        }
        waitForExpectations()
        
        trained = false
        tries = 0
        while(!trained) {
            tries += 1
            let description = "Get the updated classifier and make sure there are 2 classes."
            let expectation = self.expectation(description: description)
            visualRecognition.getClassifier(withID: newClassifierID, failure: failWithError) {
                classifier in
                
                if classifier.status == "ready" {
                    XCTAssertEqual(classifier.classes.count, 2)
                    trained = true
                }
                expectation.fulfill()
            }
            waitForExpectations()
            
            if tries > 5 {
                let description = "Delete the new classifier."
                let expectation = self.expectation(description: description)
                
                visualRecognition.deleteClassifier(withID: newClassifierID, failure: failWithError) {
                    expectation.fulfill()
                }
                waitForExpectations()
                
                XCTFail("Could not update the classifier. Try again later.")
            }
            
            sleep(5)
        }
        
        let description4 = "Delete the custom classifier."
        let expectation4 = expectation(description: description4)
        
        visualRecognition.deleteClassifier(withID: newClassifierID, failure: failWithError) {
            expectation4.fulfill()
        }
        waitForExpectations()
    }
    
    /** Update the classifier with a negative example. */
    func testUpdateClassifierWithNegativeExample() {
        let description1 = "Train a new classifier with positive examples."
        let expectation1 = expectation(description: description1)
        
        let name = "swift-sdk-unit-test-negative-update"
        let cars = PositiveExample(name: "car", examples: examplesCars)
        let classes = [cars]
        
        var classifierID: String?
        visualRecognition.createClassifier(
            withName: name,
            positiveExamples: classes,
            negativeExamples: examplesTrucks,
            failure: failWithError) { classifier in
                XCTAssertEqual(classifier.name, name)
                XCTAssertEqual(classifier.classes.count, 1)
                classifierID = classifier.classifierID
                expectation1.fulfill()
        }
        waitForExpectations()
        
        guard let newClassifierID = classifierID else {
            XCTFail("Failed to create a new classifier due to free account.")
            return
        }
        
        var trained = false
        var tries = 0
        while(!trained) {
            tries += 1
            let description = "Get the new classifier."
            let expectation = self.expectation(description: description)
            visualRecognition.getClassifier(withID: newClassifierID, failure: failWithError) {
                classifier in
                
                if classifier.status == "ready" {
                    trained = true
                }
                expectation.fulfill()
            }
            waitForExpectations()
            
            if tries > 5 {
                let description = "Delete the new classifier."
                let expectation = self.expectation(description: description)
                
                visualRecognition.deleteClassifier(withID: newClassifierID, failure: failWithError) {
                    expectation.fulfill()
                }
                waitForExpectations()
                
                XCTFail("Could not train a new classifier. Try again later.")
            }
            
            sleep(5)
        }
        
        let description2 = "Update the classifier with a negative example."
        let expectation2 = expectation(description: description2)
        visualRecognition.updateClassifier(
            withID: newClassifierID,
            negativeExamples: examplesBaseball,
            failure: failWithError) { classifier in
                XCTAssertEqual(classifier.name, name)
                expectation2.fulfill()
        }
        waitForExpectations()
        
        trained = false
        tries = 0
        while(!trained) {
            tries += 1
            let description = "Get the updated classifier and make sure there is 1 class."
            let expectation = self.expectation(description: description)
            visualRecognition.getClassifier(withID: newClassifierID, failure: failWithError) {
                classifier in
                
                if classifier.status == "ready" {
                    XCTAssertEqual(classifier.classes.count, 1)
                    trained = true
                }
                expectation.fulfill()
            }
            waitForExpectations()
            
            if tries > 5 {
                let description = "Delete the new classifier."
                let expectation = self.expectation(description: description)
                
                visualRecognition.deleteClassifier(withID: newClassifierID, failure: failWithError) {
                    expectation.fulfill()
                }
                waitForExpectations()
                
                XCTFail("Could not update the classifier. Try again later.")
            }
            
            sleep(5)
        }
        
        let description4 = "Delete the custom classifier."
        let expectation4 = expectation(description: description4)
        
        visualRecognition.deleteClassifier(withID: newClassifierID, failure: failWithError) {
            expectation4.fulfill()
        }
        waitForExpectations()
    }
    
    /** Classify an image by URL using the default classifier and all default parameters. */
    func testClassifyByURL1() {
        let description = "Classify an image by URL using the default classifier."
        let expectation = self.expectation(description: description)
        
        visualRecognition.classify(image: obamaURL, failure: failWithError) {
            classifiedImages in
            
            // verify classified images object
            XCTAssertNil(classifiedImages.warnings)
            XCTAssertEqual(classifiedImages.images.count, 1)
            
            // verify the image's metadata
            let image = classifiedImages.images.first
            XCTAssertEqual(image?.sourceURL, self.obamaURL)
            XCTAssertEqual(image?.resolvedURL, self.obamaURL)
            XCTAssertNil(image?.image)
            XCTAssertNil(image?.error)
            XCTAssertEqual(image?.classifiers.count, 1)
            
            // verify the image's classifier
            let classifier = image?.classifiers.first
            XCTAssertEqual(classifier?.classifierID, "default")
            XCTAssertEqual(classifier?.name, "default")
            XCTAssertEqual(classifier?.classes.count, 1)
            XCTAssertEqual(classifier?.classes.first?.classification, "person")
            if let score = classifier?.classes.first?.score {
                XCTAssertGreaterThan(score, 0.5)
            }
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Classify an image by URL using the default classifier and specifying default parameters. */
    func testClassifyByURL2() {
        let description = "Classify an image by URL using the default classifier."
        let expectation = self.expectation(description: description)
        
        visualRecognition.classify(
            image: obamaURL,
            owners: ["IBM"],
            classifierIDs: ["default"],
            threshold: 0.5,
            language: "en",
            failure: failWithError)
        {
            classifiedImages in
            
            // verify classified images object
            XCTAssertNil(classifiedImages.warnings)
            XCTAssertEqual(classifiedImages.images.count, 1)
            
            // verify the image's metadata
            let image = classifiedImages.images.first
            XCTAssertEqual(image?.sourceURL, self.obamaURL)
            XCTAssertEqual(image?.resolvedURL, self.obamaURL)
            XCTAssertNil(image?.image)
            XCTAssertNil(image?.error)
            XCTAssertEqual(image?.classifiers.count, 1)
            
            // verify the image's classifier
            let classifier = image?.classifiers.first
            XCTAssertEqual(classifier?.classifierID, "default")
            XCTAssertEqual(classifier?.name, "default")
            XCTAssertEqual(classifier?.classes.count, 1)
            XCTAssertEqual(classifier?.classes.first?.classification, "person")
            if let score = classifier?.classes.first?.score {
                XCTAssertGreaterThan(score, 0.5)
            }
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Classify an image by URL using a custom classifier and all default parameters. */
    func testClassifyByURL3() {
        let description = "Classify an image by URL using a custom classifier."
        let expectation = self.expectation(description: description)
        
        visualRecognition.classify(image: carURL, classifierIDs: [classifierID!], failure: failWithError) {
            classifiedImages in
            
            // verify classified images object
            XCTAssertNil(classifiedImages.warnings)
            XCTAssertEqual(classifiedImages.images.count, 1)
            
            // verify the image's metadata
            let image = classifiedImages.images.first
            XCTAssertEqual(image?.sourceURL, self.carURL)
            XCTAssertEqual(image?.resolvedURL, self.carURL)
            XCTAssertNil(image?.image)
            XCTAssertNil(image?.error)
            XCTAssertEqual(image?.classifiers.count, 1)
            
            // verify the image's classifier
            let classifier = image?.classifiers.first
            XCTAssertEqual(classifier?.classifierID, self.classifierID!)
            XCTAssertEqual(classifier?.name, self.classifierName)
            XCTAssertEqual(classifier?.classes.count, 1)
            XCTAssertEqual(classifier?.classes.first?.classification, "car")
            if let score = classifier?.classes.first?.score {
                XCTAssertGreaterThan(score, 0.5)
            }
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Classify an image by URL using a custom classifier and specifying default parameters. */
    func testClassifyByURL4() {
        let description = "Classify an image by URL using a custom classifier."
        let expectation = self.expectation(description: description)
        
        visualRecognition.classify(
            image: carURL,
            owners: ["me"],
            classifierIDs: [classifierID!],
            threshold: 0.5,
            language: "en",
            failure: failWithError)
        {
            classifiedImages in
            
            // verify classified images object
            XCTAssertNil(classifiedImages.warnings)
            XCTAssertEqual(classifiedImages.images.count, 1)
            
            // verify the image's metadata
            let image = classifiedImages.images.first
            XCTAssertEqual(image?.sourceURL, self.carURL)
            XCTAssertEqual(image?.resolvedURL, self.carURL)
            XCTAssertNil(image?.image)
            XCTAssertNil(image?.error)
            XCTAssertEqual(image?.classifiers.count, 1)
            
            // verify the image's classifier
            let classifier = image?.classifiers.first
            XCTAssertEqual(classifier?.classifierID, self.classifierID!)
            XCTAssertEqual(classifier?.name, self.classifierName)
            XCTAssertEqual(classifier?.classes.count, 1)
            XCTAssertEqual(classifier?.classes.first?.classification, "car")
            if let score = classifier?.classes.first?.score {
                XCTAssertGreaterThan(score, 0.5)
            }
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Classify an image by URL with both the default classifier and a custom classifier. */
    func testClassifyByURL5() {
        let description = "Classify an image by URL using a custom classifier."
        let expectation = self.expectation(description: description)
        
        visualRecognition.classify(image: carURL, classifierIDs: ["default", classifierID!], failure: failWithError) {
            classifiedImages in
            
            // verify classified images object
            XCTAssertNil(classifiedImages.warnings)
            XCTAssertEqual(classifiedImages.images.count, 1)
            
            // verify the image's metadata
            let image = classifiedImages.images.first
            XCTAssertEqual(image?.sourceURL, self.carURL)
            XCTAssertEqual(image?.resolvedURL, self.carURL)
            XCTAssertNil(image?.image)
            XCTAssertNil(image?.error)
            XCTAssertEqual(image?.classifiers.count, 2)
            
            // verify the image's default classifier
            let classifier1 = image?.classifiers.first
            XCTAssertEqual(classifier1?.classifierID, "default")
            XCTAssertEqual(classifier1?.name, "default")
            XCTAssertEqual(classifier1?.classes.count, 4)
            XCTAssertEqual(classifier1?.classes.first?.classification, "car")
            if let score = classifier1?.classes.first?.score {
                XCTAssertGreaterThan(score, 0.5)
            }
            
            // verify the image's custom classifier
            let classifier2 = image?.classifiers.last
            XCTAssertEqual(classifier2?.classifierID, self.classifierID!)
            XCTAssertEqual(classifier2?.name, self.classifierName)
            XCTAssertEqual(classifier2?.classes.count, 1)
            XCTAssertEqual(classifier2?.classes.first?.classification, "car")
            if let score = classifier2?.classes.first?.score {
                XCTAssertGreaterThan(score, 0.5)
            }
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Classify an uploaded image using the default classifier and all default parameters. */
    func testClassifyImage1() {
        let description = "Classify an uploaded image using the default classifier."
        let expectation = self.expectation(description: description)
        
        visualRecognition.classify(imageFile: car, failure: failWithError) {
            classifiedImages in
            
            // verify classified images object
            XCTAssertNil(classifiedImages.warnings)
            XCTAssertEqual(classifiedImages.images.count, 1)
            
            // verify the image's metadata
            let image = classifiedImages.images.first
            XCTAssertNil(image?.sourceURL)
            XCTAssertNil(image?.resolvedURL)
            XCTAssert(image?.image == "car.png")
            XCTAssertNil(image?.error)
            XCTAssertEqual(image?.classifiers.count, 1)
            
            // verify the image's classifier
            let classifier = image?.classifiers.first
            XCTAssertEqual(classifier?.classifierID, "default")
            XCTAssertEqual(classifier?.name, "default")
            XCTAssertEqual(classifier?.classes.count, 4)
            XCTAssertEqual(classifier?.classes.first?.classification, "car")
            if let score = classifier?.classes.first?.score {
                XCTAssertGreaterThan(score, 0.5)
            }
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Classify an uploaded image using the default classifier and specifying default parameters. */
    func testClassifyImage2() {
        let description = "Classify an uploaded image using the default classifier."
        let expectation = self.expectation(description: description)
        
        visualRecognition.classify(
            imageFile: car,
            owners: ["IBM"],
            classifierIDs: ["default"],
            threshold: 0.5,
            language: "en",
            failure: failWithError)
        {
            classifiedImages in
            
            // verify classified images object
            XCTAssertNil(classifiedImages.warnings)
            XCTAssertEqual(classifiedImages.images.count, 1)
            
            // verify the image's metadata
            let image = classifiedImages.images.first
            XCTAssertNil(image?.sourceURL)
            XCTAssertNil(image?.resolvedURL)
            XCTAssert(image?.image == "car.png")
            XCTAssertNil(image?.error)
            XCTAssertEqual(image?.classifiers.count, 1)
            
            // verify the image's classifier
            let classifier = image?.classifiers.first
            XCTAssertEqual(classifier?.classifierID, "default")
            XCTAssertEqual(classifier?.name, "default")
            XCTAssertEqual(classifier?.classes.count, 4)
            XCTAssertEqual(classifier?.classes.first?.classification, "car")
            if let score = classifier?.classes.first?.score {
                XCTAssertGreaterThan(score, 0.5)
            }
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Classify an uploaded image using a custom classifier and all default parameters. */
    func testClassifyImage3() {
        let description = "Classify an uploaded image using a custom classifier."
        let expectation = self.expectation(description: description)
        
        visualRecognition.classify(imageFile: car, classifierIDs: [classifierID!], failure: failWithError) {
            classifiedImages in
            
            // verify classified images object
            XCTAssertNil(classifiedImages.warnings)
            XCTAssertEqual(classifiedImages.images.count, 1)
            
            // verify the image's metadata
            let image = classifiedImages.images.first
            XCTAssertNil(image?.sourceURL)
            XCTAssertNil(image?.resolvedURL)
            XCTAssert(image?.image == "car.png")
            XCTAssertNil(image?.error)
            XCTAssertEqual(image?.classifiers.count, 1)
            
            // verify the image's classifier
            let classifier = image?.classifiers.first
            XCTAssertEqual(classifier?.classifierID, self.classifierID!)
            XCTAssertEqual(classifier?.name, self.classifierName)
            XCTAssertEqual(classifier?.classes.count, 1)
            XCTAssertEqual(classifier?.classes.first?.classification, "car")
            if let score = classifier?.classes.first?.score {
                XCTAssertGreaterThan(score, 0.5)
            }
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Classify an uploaded image using a custom classifier and specifying default parameters. */
    func testClassifyImage4() {
        let description = "Classify an uploaded image using a custom classifier."
        let expectation = self.expectation(description: description)
        
        visualRecognition.classify(
            imageFile: car,
            owners: ["me"],
            classifierIDs: [classifierID!],
            threshold: 0.5,
            language: "en",
            failure: failWithError)
        {
            classifiedImages in
            
            // verify classified images object
            XCTAssertNil(classifiedImages.warnings)
            XCTAssertEqual(classifiedImages.images.count, 1)
            
            // verify the image's metadata
            let image = classifiedImages.images.first
            XCTAssertNil(image?.sourceURL)
            XCTAssertNil(image?.resolvedURL)
            XCTAssert(image?.image == "car.png")
            XCTAssertNil(image?.error)
            XCTAssertEqual(image?.classifiers.count, 1)
            
            // verify the image's classifier
            let classifier = image?.classifiers.first
            XCTAssertEqual(classifier?.classifierID, self.classifierID!)
            XCTAssertEqual(classifier?.name, self.classifierName)
            XCTAssertEqual(classifier?.classes.count, 1)
            XCTAssertEqual(classifier?.classes.first?.classification, "car")
            if let score = classifier?.classes.first?.score {
                XCTAssertGreaterThan(score, 0.5)
            }
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Classify an uploaded image with both the default classifier and a custom classifier. */
    func testClassifyImage5() {
        let description = "Classify an uploaded image with the default and custom classifiers."
        let expectation = self.expectation(description: description)
        
        visualRecognition.classify(
            imageFile: car,
            classifierIDs: ["default", classifierID!],
            failure: failWithError)
        {
            classifiedImages in
            
            // verify classified images object
            XCTAssertNil(classifiedImages.warnings)
            XCTAssertEqual(classifiedImages.images.count, 1)
            
            // verify the image's metadata
            let image = classifiedImages.images.first
            XCTAssertNil(image?.sourceURL)
            XCTAssertNil(image?.resolvedURL)
            XCTAssert(image?.image == "car.png")
            XCTAssertNil(image?.error)
            XCTAssertEqual(image?.classifiers.count, 2)
            
            // verify the image's default classifier
            let classifier1 = image?.classifiers.first
            XCTAssertEqual(classifier1?.classifierID, "default")
            XCTAssertEqual(classifier1?.name, "default")
            XCTAssertEqual(classifier1?.classes.count, 4)
            XCTAssertEqual(classifier1?.classes.first?.classification, "car")
            if let score = classifier1?.classes.first?.score {
                XCTAssertGreaterThan(score, 0.5)
            }
            
            // verify the image's custom classifier
            let classifier2 = image?.classifiers.last
            XCTAssertEqual(classifier2?.classifierID, self.classifierID!)
            XCTAssertEqual(classifier2?.name, self.classifierName)
            XCTAssertEqual(classifier2?.classes.count, 1)
            XCTAssertEqual(classifier2?.classes.first?.classification, "car")
            if let score = classifier2?.classes.first?.score {
                XCTAssertGreaterThan(score, 0.5)
            }
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Classify multiple images using a custom classifier. */
    func testClassifyImage6() {
        let description = "Classify multiple images using a custom classifier."
        let expectation = self.expectation(description: description)
        
        visualRecognition.classify(
            imageFile: examplesCars,
            classifierIDs: ["default", classifierID!],
            failure: failWithError)
        {
            classifiedImages in
            
            // verify classified images object
            XCTAssertNil(classifiedImages.warnings)
            XCTAssertEqual(classifiedImages.images.count, 16)
            
            for image in classifiedImages.images {
                // verify the image's metadata
                XCTAssertNil(image.sourceURL)
                XCTAssertNil(image.resolvedURL)
                XCTAssert(image.image?.hasPrefix("car") == true)
                XCTAssertNil(image.error)
                XCTAssertEqual(image.classifiers.count, 2)
            
                // verify the image's default classifier
                let classifier1 = image.classifiers.first
                XCTAssertEqual(classifier1?.classifierID, "default")
                XCTAssertEqual(classifier1?.name, "default")
                XCTAssert(classifier1!.classes.count >= 1)
                let classification = classifier1?.classes.first?.classification
                XCTAssert(classification == "car" || classification == "vehicle")
                if let score = classifier1?.classes.first?.score {
                    XCTAssertGreaterThan(score, 0.5)
                }
                
                // verify the image's custom classifier
                let classifier2 = image.classifiers.last
                XCTAssertEqual(classifier2?.classifierID, self.classifierID!)
                XCTAssertEqual(classifier2?.name, self.classifierName)
                XCTAssertEqual(classifier2?.classes.count, 1)
                XCTAssertEqual(classifier2?.classes.first?.classification, "car")
                if let score = classifier2?.classes.first?.score {
                    XCTAssertGreaterThan(score, 0.5)
                }
            }
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Detect faces by URL. */
    func testDetectFacesByURL() {
        let description = "Detect faces by URL."
        let expectation = self.expectation(description: description)
        
        visualRecognition.detectFaces(inImage: obamaURL, failure: failWithError) {
            faceImages in
            
            // verify face images object
            XCTAssertEqual(faceImages.imagesProcessed, 1)
            XCTAssertNil(faceImages.warnings)
            XCTAssertEqual(faceImages.images.count, 1)
            
            // verify the face image object
            let face = faceImages.images.first
            XCTAssertEqual(face?.sourceURL, self.obamaURL)
            XCTAssertEqual(face?.resolvedURL, self.obamaURL)
            XCTAssertNil(face?.image)
            XCTAssertNil(face?.error)
            XCTAssertEqual(face?.faces.count, 1)
            
            // verify the age
            let age = face?.faces.first?.age
            XCTAssertGreaterThanOrEqual(age!.min!, 45)
            XCTAssertLessThanOrEqual(age!.max!, 54)
            XCTAssertGreaterThanOrEqual(age!.score, 0.25)
            
            // verify the face location
            let location = face?.faces.first?.location
            XCTAssertEqual(location?.height, 229)
            XCTAssertEqual(location?.left, 213)
            XCTAssertEqual(location?.top, 66)
            XCTAssertEqual(location?.width, 189)
            
            // verify the gender
            let gender = face?.faces.first?.gender
            XCTAssertEqual(gender!.gender, "MALE")
            XCTAssertGreaterThanOrEqual(gender!.score, 0.75)
            
            // verify the identity
            let identity = face?.faces.first?.identity
            XCTAssertEqual(identity!.name, "Barack Obama")
            XCTAssertGreaterThanOrEqual(identity!.score, 0.75)
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Detect faces in an uploaded image */
    func testDetectFacesByImage1() {
        let description = "Detect faces in an uploaded image."
        let expectation = self.expectation(description: description)
        
        visualRecognition.detectFaces(inImageFile: obama, failure: failWithError) {
            faceImages in
            
            // verify face images object
            XCTAssertEqual(faceImages.imagesProcessed, 1)
            XCTAssertNil(faceImages.warnings)
            XCTAssertEqual(faceImages.images.count, 1)
            
            // verify the face image object
            let face = faceImages.images.first
            XCTAssertNil(face?.sourceURL)
            XCTAssertNil(face?.resolvedURL)
            XCTAssertNotNil(face?.image)
            XCTAssertNil(face?.error)
            XCTAssertEqual(face?.faces.count, 1)
            
            // verify the age
            let age = face?.faces.first?.age
            XCTAssertGreaterThanOrEqual(age!.min!, 45)
            XCTAssertLessThanOrEqual(age!.max!, 54)
            XCTAssertGreaterThanOrEqual(age!.score, 0.25)
            
            // verify the face location
            let location = face?.faces.first?.location
            XCTAssertEqual(location?.height, 229)
            XCTAssertEqual(location?.left, 213)
            XCTAssertEqual(location?.top, 66)
            XCTAssertEqual(location?.width, 189)
            
            // verify the gender
            let gender = face?.faces.first?.gender
            XCTAssertEqual(gender!.gender, "MALE")
            XCTAssertGreaterThanOrEqual(gender!.score, 0.75)
            
            // verify the identity
            let identity = face?.faces.first?.identity
            XCTAssertEqual(identity!.name, "Barack Obama")
            XCTAssertGreaterThanOrEqual(identity!.score, 0.75)
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Detect faces in uploaded images. */
    func testDetectFacesByImage2() {
        let description = "Detect faces in uploaded images."
        let expectation = self.expectation(description: description)
        
        visualRecognition.detectFaces(inImageFile: faces, failure: failWithError) {
            faceImages in
            
            // verify face images object
            XCTAssertEqual(faceImages.imagesProcessed, 3)
            XCTAssertNil(faceImages.warnings)
            XCTAssertEqual(faceImages.images.count, 3)
            
            for image in faceImages.images {
                // verify the face image object
                XCTAssertNil(image.sourceURL)
                XCTAssertNil(image.resolvedURL)
                XCTAssert(image.image?.hasPrefix("faces.zip/faces/face") == true)
                XCTAssertNil(image.error)
                XCTAssertEqual(image.faces.count, 1)
                
                // verify the age
                let age = image.faces.first?.age
                XCTAssert(age!.min! >= 18)
                XCTAssert(age!.max! <= 44)
                XCTAssert(age!.score >= 0.25)
                
                // verify the face location
                let location = image.faces.first?.location
                XCTAssert(location!.height >= 100)
                XCTAssert(location!.left >= 30)
                XCTAssert(location!.top >= 20)
                XCTAssert(location!.width >= 90)
                
                // verify the gender
                let gender = image.faces.first?.gender
                XCTAssert(gender!.gender == "MALE")
                XCTAssert(gender!.score >= 0.75)
                
                // verify the identity
                if let identity = image.faces.first?.identity {
                    XCTAssertEqual(identity.name, "Tiger Woods")
                    XCTAssert(identity.score >= 0.75)
                }
            }
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** List all collections. */
    func testGetCollections() {
        let description = "List all collections."
        let expectation = self.expectation(description: description)
        
        visualRecognition.getCollections(failure: failWithError) { collections in
            for collection in collections {
                if collection.name == self.collectionName {
                    XCTAssertEqual(collection.collectionID, self.collectionID)
                    XCTAssertEqual(collection.name, self.collectionName)
                    XCTAssertNotNil(collection.images)
                    XCTAssertEqual(collection.status, "available")
                    XCTAssertEqual(collection.capacity, "1000000")
                }
            }
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Retrieve test collection details. */
    func testRetrieveCollectionDetails() {
        let description = "Retrieve test collection."
        let expectation = self.expectation(description: description)

        visualRecognition.retrieveCollectionDetails(
            withID: collectionID!,
            failure: failWithError) { collection in
                
                XCTAssertEqual(collection.collectionID, self.collectionID)
                XCTAssertEqual(collection.name, self.collectionName)
                XCTAssertNotNil(collection.images)
                XCTAssertEqual(collection.status, "available")
                XCTAssertEqual(collection.capacity, "1000000")
                
                expectation.fulfill()
        }
        waitForExpectations()
    }

    /** Add images to collection. */
    func testAddDeleteImageToCollection() {
        let description = "Add image to test collection."
        let expectation = self.expectation(description: description)

        var imageID: String?
        let imageFile = "obama.jpg"
        
        visualRecognition.addImageToCollection(
            withID: collectionID!,
            imageFile: obama,
            failure: failWithError) { collectionImages in
                
                XCTAssertEqual(1, collectionImages.imagesProcessed)
                for image in collectionImages.collectionImages {
                    if image.imageFile == imageFile {
                        imageID = image.imageID
                        expectation.fulfill()
                        return
                    }
                }
                XCTFail("Image was not successfully added to the collection.")
        }
        waitForExpectations()
        
        guard let imageIDToDelete = imageID else {
            XCTFail("Image failed to be added to collection.")
            return
        }
        
        let description2 = "Delete the image added."
        let expectation2 = self.expectation(description: description2)
        visualRecognition.deleteImageFromCollection(withID: collectionID!, imageID: imageIDToDelete, failure: failWithError) {
            expectation2.fulfill()
        }
        waitForExpectations()
    }
    
    /** Add image with metadata to collection. */
    func testAddDeleteImageWithMetadataToCollection() {
        let description = "Add image to test collection."
        let expectation = self.expectation(description: description)
        
        var imageID: String?
        let imageFile = "obama.jpg"
        
        guard let imageMetadataURL = loadMetadataFile(withName: "metadata", withExtension: "txt") else {
            XCTFail("Failed to load image metadata file.")
            return
        }
        
        visualRecognition.addImageToCollection(
            withID: collectionID!,
            imageFile: obama,
            metadata: imageMetadataURL,
            failure: failWithError) { collectionImages in
                
                XCTAssertEqual(1, collectionImages.imagesProcessed)
                for image in collectionImages.collectionImages {
                    if image.imageFile == imageFile {
                        imageID = image.imageID
                        XCTAssertNotNil(image.metadata)
                        expectation.fulfill()
                        return
                    }
                }
                XCTFail("Image was not successfully added to the collection.")
        }
        waitForExpectations()
        
        guard let imageIDToDelete = imageID else {
            XCTFail("Image failed to be added to collection.")
            return
        }
        
        let description2 = "Delete the image added."
        let expectation2 = self.expectation(description: description2)
        visualRecognition.deleteImageFromCollection(withID: collectionID!, imageID: imageIDToDelete, failure: failWithError) {
            expectation2.fulfill()
        }
        waitForExpectations()
    }
    
    // Uncomment when .PNG bug is fixed. Currently this test fails at the XCTAssertEqual
    // callback is nil
//    /** Add images to collection. */
//    func testAddDeletePNGImageToCollection() {
//        let description = "Add image to test collection."
//        let expectation = self.expectation(description: description)
//        
//        let imageFile = "car.png"
//        
//        visualRecognition.addImageToCollection(
//            collectionID: collectionID!,
//            imageFile: car,
//            failure: failWithError) { collectionImages in
//                
//                XCTAssertEqual(1, collectionImages.imagesProcessed)
//                guard let images = collectionImages.collectionImages else {
//                    return
//                }
//                for image in images {
//                    if image.imageFile == imageFile {
//                        expectation.fulfill()
//                        return
//                    }
//                }
//                XCTFail("Image was not successfully added to the collection.")
//        }
//        waitForExpectations()
//    }
    
    /** List images in a collection. */
    func testCreateDeleteCollection() {
        let description = "Create a collection."
        let expectation = self.expectation(description: description)
        
        let name = "swift-sdk-unit-test-2"
        var collectionID: String?
        
        visualRecognition.createCollection(withName: name, failure: failWithError) { collection in
            XCTAssertEqual(collection.name, name)
            collectionID = collection.collectionID
            expectation.fulfill()
        }
        waitForExpectations()
        
        let description2 = "Delete collection."
        let expectation2 = self.expectation(description: description2)
        
        guard let collection = collectionID else {
            return
        }
        visualRecognition.deleteCollection(withID: collection) {
            expectation2.fulfill()
        }
        waitForExpectations()
    }
    
    /** List images in the test collection. */
    func testListImagesInCollection() {
        let description = "List images in collection."
        let expectation = self.expectation(description: description)
        let failure = { (error: Error) in XCTFail("Could not list images in collection.") }
        let imageFile = "sign.jpg"
        
        visualRecognition.getImagesInCollection(withID: collectionID!, failure: failure) { images in
            XCTAssertEqual(2, images.count)
            for image in images {
                if image.imageFile == imageFile {
                    expectation.fulfill()
                    return
                }
            }
            XCTFail("Could not list images in collection.")
        }
        waitForExpectations()
    }

    /** Find similar images using the default classifier and all default parameters. */
    func testSimilarImages() {
        let description = "Find images similar to an uploaded image using the default classifier."
        let expectation = self.expectation(description: description)
        
        let imageFile = "obama.jpg"
        
        visualRecognition.findSimilarImagesInCollection(
            withID: collectionID!,
            imageFile: obama,
            failure: failWithError) { similarImages in
                XCTAssertEqual(imageFile, similarImages.imageFile)
                XCTAssertNotEqual(0, similarImages.similarImages.count)
                XCTAssertEqual(1, similarImages.imagesProcessed)
                for image in similarImages.similarImages {
                    XCTAssertNotNil(image.score)
                }
                expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Test error message for finding similar images to an invalid file type. */
    func testNegativeSimilarImages() {
        let description = "Find images similar to an uploaded image using the default classifier."
        let expectation = self.expectation(description: description)
        
        visualRecognition.findSimilarImagesInCollection(
            withID: collectionID!,
            imageFile: examplesCars,
            failure: { (Error) in
                XCTAssertEqual("Invalid image file", Error.localizedDescription)
                expectation.fulfill()
            },
            success: { (SimilarImages) in return})
        waitForExpectations()
    }
}
