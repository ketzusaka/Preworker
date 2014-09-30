Preworker is a tool to help you do work in your application before it is needed. You'll often have times in your application where it may be useful to build a product of some data before it is needed to allow a better user experience. A few examples are:

- Build a complex path that represents a users run before they tap into it.
- Download a large version of an image before the user views the full size.
- Apply a filters to an image before the user taps it so it immediately renders.
- Package a document before it the user saves it.

## Features

### Closure-based work

Units of work are defined in a closure so you don't need to do any subclassing to start using Preworker. Each work closure is passed an object, called a Preworker Context, to enable progress tracking and asynchronous work to be done within the closure as well.

### Progress tracking

You can track the progress of the work being done and be notified as the work progresses.

### Asynchronous work within the main unit of work

Preworker makes use of libdispatch to support multiple units of work within the main unit of work. This makes downloads possible, among other things. Here's an example:

```swift
var downloadWorker = Preworker<NSData> { context in
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    context++ // Tells the context we are starting an operation
    var downloadData: NSData?
    var downloadError: NSError?
    let task = session.dataTaskWithURL(NSURL(string: "http://ipv4.download.thinkbroadband.com/100MB.zip")) { data, response, error in
        downloadData = data
        downloadError = error
        context-- // Tells the context we finished an operation
    }

    task.resume()

    // This asks the context to wait until all operations have been finished.
    context.waitForPendingOperations()

    return (downloadData, downloadError)
}.start()

```

## Getting Started

* Download Preworker and check out the example operations in the sample application
* Start using Preworker by copying the files in the Sources directory to your own project.

We'll include support for Cocoapods when it's possible to!

## Requirements

Preworker is built using Swift, and makes heavy use of the advanced features of Swift, so it isn't available in Objective-C. It supports iOS 7.0+, or Mac OS X 10.10+.

## Usage

Preworker is used to create units of work. They can be any type of work that you may want done separately, but usually it would be done in the background.

Check out the [Using Preworker](https://github.com/ketzusaka/Preworker/wiki/Using-Preworker) document to see some examples on how you could use Preworker.

## Contact

* If you need help or have a general question use [Stack Overflow](https://stackoverflow.com/)
* If you've found a bug or have a feature request [open an issue](https://github.com/ketzusaka/TableSchemer/issues/new)

## License

Copyright (c) 2014, James Richard All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. Neither the name of James Richard nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL James Richard, Inc BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.