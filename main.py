import tkinter as tk
from tkinter import ttk
import csv
from datetime import datetime
import os

# Define shared CSV path
# Correctly resolve path, ensuring it works if __file__ is empty (e.g. "shared_communication/commands.csv")
dirname = os.path.dirname(__file__)
SHARED_CSV_PATH = os.path.join(dirname if dirname else ".", "shared_communication", "commands.csv")

# Store timestamps of acknowledged commands
acknowledged_timestamps = set()

# Create the main application window
root = tk.Tk()
root.title("Command UI")
root.configure(bg="black")

# Make window large (can use root.attributes('-fullscreen', True) for fullscreen)
root.geometry("800x600")  # Adjust size as needed

# Create a canvas to simulate a rounded frame
canvas = tk.Canvas(root, bg="black", highlightthickness=0)
canvas.place(relx=1.0, rely=1.0, anchor="se", x=-20, y=-20)  # Bottom-right with margin

# Rounded rectangle simulation using create_arc and create_rectangle
width, height = 300, 100
x0, y0 = 0, 0
x1, y1 = width, height
r = 20

# Draw rounded rectangle shape on the canvas
canvas.create_arc((x0, y0, x0+r*2, y0+r*2), start=90, extent=90, fill="#1e1e1e", outline="#1e1e1e")
canvas.create_arc((x1-r*2, y0, x1, y0+r*2), start=0, extent=90, fill="#1e1e1e", outline="#1e1e1e")
canvas.create_arc((x0, y1-r*2, x0+r*2, y1), start=180, extent=90, fill="#1e1e1e", outline="#1e1e1e")
canvas.create_arc((x1-r*2, y1-r*2, x1, y1), start=270, extent=90, fill="#1e1e1e", outline="#1e1e1e")
canvas.create_rectangle((x0+r, y0, x1-r, y1), fill="#1e1e1e", outline="#1e1e1e")
canvas.create_rectangle((x0, y0+r, x1, y1-r), fill="#1e1e1e", outline="#1e1e1e")

# Create a frame on top of canvas to hold widgets
frame = tk.Frame(canvas, bg="#1e1e1e")
frame.place(x=10, y=10, width=width-20, height=height-20)

# Entry widget for command input
entry = ttk.Entry(frame)
entry.pack(side="left", fill="x", expand=True, padx=5, pady=20)

# Button widget
def run_command():
    full_command_string = entry.get()
    timestamp = datetime.utcnow().isoformat()

    command_name = full_command_string
    command_payload = ""

    if ":" in full_command_string:
        parts = full_command_string.split(":", 1)
        command_name = parts[0]
        command_payload = parts[1]

    new_row = [timestamp, "python", command_name, command_payload, "pending", ""]

    try:
        with open(SHARED_CSV_PATH, 'a', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(new_row)
        if command_payload:
            print(f"Command '{command_name}' with payload '{command_payload}' sent to CSV.")
        else:
            print(f"Command '{command_name}' sent to CSV.")
    except Exception as e:
        print(f"Error writing to CSV: {e}")

    entry.delete(0, tk.END)

button = ttk.Button(frame, text="Run Command", command=run_command)
button.pack(side="right", padx=5)

def listen_for_responses():
    if not os.path.exists(SHARED_CSV_PATH):
        print(f"Error: CSV file not found at {SHARED_CSV_PATH}")
        return

    try:
        with open(SHARED_CSV_PATH, 'r', newline='') as csvfile:
            reader = csv.reader(csvfile)
            header = next(reader, None) # Skip header row

            for row in reader:
                try:
                    # Unpack with a more descriptive name for payload from CSV
                    timestamp, source_app, cmd_name_from_csv, cmd_payload_from_csv, status, result_payload = row
                    if source_app == "python" and timestamp not in acknowledged_timestamps:
                        payload_info = f"(Payload: '{cmd_payload_from_csv}')" if cmd_payload_from_csv else ""
                        if status == "success":
                            print(f"Python App: Command '{cmd_name_from_csv}' {payload_info} (ID: {timestamp}) completed successfully. Result: '{result_payload}'")
                            acknowledged_timestamps.add(timestamp)
                        elif status == "failed":
                            print(f"Python App: Command '{cmd_name_from_csv}' {payload_info} (ID: {timestamp}) failed. Reason: '{result_payload}'")
                            acknowledged_timestamps.add(timestamp)
                except IndexError:
                    print(f"Skipping malformed row: {row}")
                except ValueError: # Handles cases where row might not have enough values to unpack
                    print(f"Skipping malformed row (ValueError): {row}")
    except Exception as e:
        print(f"Error reading CSV: {e}")

def listen_for_responses_wrapper():
    listen_for_responses()
    root.after(3000, listen_for_responses_wrapper)

# Start listening for responses
root.after(3000, listen_for_responses_wrapper)

root.mainloop()
