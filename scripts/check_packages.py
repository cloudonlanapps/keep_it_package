import requests
import json

def get_package_info(package_name):
    url = f"https://pub.dev/api/packages/{package_name}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Failed to fetch info for package: {package_name}")
        return None

def check_platform_support(package_name, platforms):
    package_info = get_package_info(package_name)

    print(type(package_info))
    #data = json.loads(package_info.__str__)
    formatted_json = json.dumps(package_info, indent=4)
    with open('package_info.json', 'a') as file:
      file.write(formatted_json)
      file.write(',') 
    if package_info:
        supported_platforms = package_info.get('latest', {}).get('pubspec', {}).get('platforms', {})
        print(f"Package '{package_name}' supports the following platforms: {list(supported_platforms.keys())}")
        for platform in platforms:
            if platform in supported_platforms:
                print(f"  - {platform}: Supported")
            else:
                print(f"  - {platform}: Not Supported")
    else:
        print(f"Could not retrieve platform support information for package: {package_name}")

if __name__ == "__main__":
    packages = [
        "provider",  # Example package names
        "http",
        "shared_preferences",
        "flutter_webview_plugin",
    ]
    platforms = ["android", "ios", "web", "linux", "macos", "windows"]
    with open('package_info.json', 'a') as file:
        pass
    for package in packages:
        check_platform_support(package, platforms)
        

