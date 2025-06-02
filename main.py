import tkinter as tk
from tkinter import ttk

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
    print(f"Running command: {entry.get()}")

button = ttk.Button(frame, text="Run Command", command=run_command)
button.pack(side="right", padx=5)

root.mainloop()
