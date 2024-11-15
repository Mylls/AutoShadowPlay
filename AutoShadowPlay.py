# MIT License
#
# Copyright (c) 2024 Swonk
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


import os
import time
import pyautogui
import tkinter as tk
from tkinter import filedialog, messagebox
import json

CONFIG_FILE = "config.json"

# Default values
default_screenshot_folder = "C:/Program Files (x86)/World of Warcraft/_retail_/Screenshots"
default_shadowplay_keybind = ['alt', 'f10']

# Load or create config
def load_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r') as file:
            return json.load(file)
    else:
        return {
            "screenshot_folder": default_screenshot_folder,
            "shadowplay_keybind": default_shadowplay_keybind
        }

def save_config(config):
    with open(CONFIG_FILE, 'w') as file:
        json.dump(config, file)

# GUI for first-time setup
def first_time_setup(config):
    def save_settings():
        # Save screenshot folder
        config["screenshot_folder"] = folder_var.get()
        
        # Save keybind
        keybind = keybind_entry.get().strip().lower().split("+")
        config["shadowplay_keybind"] = keybind
        
        save_config(config)
        messagebox.showinfo("Settings Saved", "Your settings have been saved successfully!")
        root.destroy()

    def browse_folder():
        folder_selected = filedialog.askdirectory(initialdir=default_screenshot_folder)
        if folder_selected:
            folder_var.set(folder_selected)

    root = tk.Tk()
    root.title("First-Time Setup")
    root.geometry("400x200")

    # Screenshot folder setup
    tk.Label(root, text="Screenshot Folder:").pack(pady=5)
    folder_var = tk.StringVar(value=config["screenshot_folder"])
    folder_entry = tk.Entry(root, textvariable=folder_var, width=50)
    folder_entry.pack()
    tk.Button(root, text="Browse", command=browse_folder).pack(pady=5)

    # ShadowPlay keybind setup
    tk.Label(root, text="ShadowPlay Keybind (e.g., Alt+F10):").pack(pady=5)
    keybind_entry = tk.Entry(root, width=20)
    keybind_entry.insert(0, "+".join(config["shadowplay_keybind"]))
    keybind_entry.pack()

    # Save button
    tk.Button(root, text="Save Settings", command=save_settings).pack(pady=20)

    root.mainloop()

# Main script
config = load_config()

# If config file does not exist, run the first-time setup
if not os.path.exists(CONFIG_FILE):
    first_time_setup(config)

screenshot_folder = config["screenshot_folder"]
shadowplay_keybind = config["shadowplay_keybind"]

# Track the existing screenshots at startup
existing_screenshots = set(os.listdir(screenshot_folder))

print("Monitoring for new screenshots...")

try:
    while True:
        # Get the current list of screenshots
        current_screenshots = set(os.listdir(screenshot_folder))
        
        # Find any new screenshots
        new_screenshots = current_screenshots - existing_screenshots
        if new_screenshots:
            print("New screenshot detected. Triggering ShadowPlay.")
            pyautogui.hotkey(*shadowplay_keybind)
            
            # Update the tracked screenshots
            existing_screenshots = current_screenshots
        
        # Check every 0.5 seconds
        time.sleep(0.5)

except KeyboardInterrupt:
    print("Script terminated by user.")