import PackageDescription

let package = Package(
    name: "PMJackson",
    dependencies: [
        .Package(url: "https://github.com/postmates/PMJSON.git", majorVersion: 2)
    ]
)

package.exclude = ["Tests"]
