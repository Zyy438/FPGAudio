# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.

'''
ELEC5552 design project
written by Zyy Zhou(22670661)
used to decide a high frequency or a low frequency signal generated
'''
import serial
import tkinter as tk

# define the dunctionlity to send instruction and set generated signal as high frequency
def set_high():
    com = serial.Serial('COM5', 9600)
    print(com)
    success_bytes = com.write(chr(0x01).encode("utf-8"))
    print(success_bytes)
    print(com.read().hex())

# define the dunctionlity to send instruction and set generated signal as high frequency
def set_low():
    com = serial.Serial('COM5', 9600)
    print(com)
    success_bytes = com.write(chr(0x00).encode("utf-8"))
    print(success_bytes)
    print(com.read().hex())

# instance an window
window = tk.Tk()
# name the defined window
window.title('ELEC5552 FIR signal controler')
# set size of the defined window
window.geometry('300x100')
# set a tag on the top of the window
tag = tk.Label(window,text='ELEC5552 TEAM11',bg='gray',font=('Arial',12),width=30,height=2)
tag.pack()
# create a button to set the frequency as high
b1 = tk.Button(window, text='set_high', font=('Arial',10),width=10,height=1,command=set_high)
b1.pack()
# create a button to set the frequency as low
b2 = tk.Button(window, text='set_low', font=('Arial',10),width=10,height=1,command=set_low)
b2.pack()
# let the window keep showing
window.mainloop()