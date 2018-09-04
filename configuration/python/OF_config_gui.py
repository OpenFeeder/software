# -*- coding: utf-8 -*-
"""
Created on Wed Aug  8 10:34:18 2018

@author: jerome
"""

import sys
from tkinter import Tk, Label, Checkbutton, Radiobutton, Entry, Button, \
                        Canvas, Text, OptionMenu, StringVar, IntVar, END, \
                        filedialog, DISABLED, NORMAL
from tkinter.colorchooser import askcolor
from tkinter.font import Font
from functools import partial
import os
import configparser
import datetime
import tempfile

version = {'major': 1, 'minor': 0, 'patch': 0}
about = {'author': 'Jerome Briot', 'contact': 'jbtechlab@gmail.com'}

default = {'ServoClosingSpeedFactor': 4, 'ServoOpeningSpeedFactor': 10,
           'ServoClosePosition': 600, 'ServoOpenPosition': 1400,
           'ServoMsStep': 20, 'WakeUpMinute': 30, 'WakeUpHour': 6,
           'SleepMinute': 00, 'SleepHour': 19, 'RGBColorA': [0, 35, 0],
           'RGBColorB': [35, 0, 0]}


def set_default_time():

    idx = hours.index('{:02d}'.format(default['WakeUpHour']))
    popupmenu_var_wake_up_hour.set(hours[idx])
    idx = minutes.index('{:02d}'.format(default['WakeUpMinute']))
    popupmenu_var_wake_up_minute.set(minutes[idx])
    idx = hours.index('{:02d}'.format(default['SleepHour']))
    popupmenu_var_sleep_hour.set(hours[idx])
    idx = minutes.index('{:02d}'.format(default['SleepMinute']))
    popupmenu_var_sleep_minute.set(minutes[idx])


def set_scenario(event):

    scenario = popupmenu_var_scenario.get()
    idx = scenario.index(' - ')

    scenario = scenario[idx+3:]

    if scenario == 'None':

        pass

    elif scenario == 'OpenBar':

        # Time
        set_default_time()

        # Logs
        check_var_log_birds.set('1')
        check_var_log_events.set('1')
        check_var_log_errors.set('1')

        # PIT tags
        check_button_pit_tags_1.config(text='')
        check_button_pit_tags_2.config(text='')
        check_button_pit_tags_3.config(text='')
        check_button_pit_tags_4.config(text='')
        check_value_pit_tags_1.set(0)
        check_value_pit_tags_2.set(0)
        check_value_pit_tags_3.set(0)
        check_value_pit_tags_4.set(0)

    elif scenario == 'DoorHabituation':
        pass
    elif scenario == 'Go-NoGo':
        pass
    elif scenario == 'LongTermSpatialMemory':
        pass
    elif scenario == 'WorkingSpatialMemory':
        pass
    elif scenario == 'ColorAssociativeLearning':
        pass
    elif scenario == 'RiskAversion':
        pass
    elif scenario == 'PatchProbability':
        pass


def preview_ini_file(event):

    tempdir = tempfile.TemporaryDirectory()

    pathname = tempdir.name
    filename = 'CONFIG.INI'

    of_write_ini(pathname, filename)

    text_preview.config(state=NORMAL)

    text_preview.delete(1.0, END)

    filepath = os.path.join(pathname, filename)

    text_preview.tag_config('section', foreground='#8000FF')

    with open(filepath) as f:
        for line in f:
            if line == '\n':
                continue
            if line[0] == '[':
                text_preview.insert(END, line, 'section')
            else:
                text_preview.insert(END, line)

    text_preview.config(state=DISABLED)

    tempdir.cleanup()


def load_ini_file():

    filename = filedialog.askopenfilename(initialdir="/",
                                          title="Select file",
                                          initialfile='CONFIG.INI',
                                          filetypes=[("INI files", "*.INI")])

    if filename:
        filename = filename.upper()

        config = of_read_ini(filename)

        populate_ui(config)
        update_servoMove_time()


def export_ini_file():

    filename = filedialog.asksaveasfilename(initialdir="/",
                                            title="Select file",
                                            initialfile='CONFIG.INI',
                                            filetypes=[("INI files", "*.INI")])

    if filename:
        filename = filename.upper()

        pathname = os.path.dirname(filename)
        filename = os.path.basename(filename)

        of_write_ini(pathname, filename)

        export_pit_tags(pathname)


def export_pit_tags(pathname):

    pass


def import_pit_tags():

    pass


def get_data_from_ui():

    config = configparser.ConfigParser()

    # Scenario
    scenario = popupmenu_var_scenario.get()
    idx = scenario.index(' - ')

    config['scenario'] = {}
    config['scenario']['num'] = scenario[0:idx]
    config['scenario']['title'] = scenario[idx+3:]

    scenario = int(scenario[0:idx])

    # Site ID
    config['siteid'] = {}
    config['siteid']['zone'] = popupmenu_var_site_name.get() + popupmenu_var_site_number.get()

    # WakeUp
    config['time'] = {}
    config['time']['wakeup_hour'] = popupmenu_var_wake_up_hour.get()
    config['time']['wakeup_minute'] = popupmenu_var_wake_up_minute.get()
    config['time']['sleep_hour'] = popupmenu_var_sleep_hour.get()
    config['time']['sleep_minute'] = popupmenu_var_sleep_minute.get()

    # Logs
    config['logs'] = {}
    config['logs']['separator'] = popupmenu_var_log_file_separator.get()
    config['logs']['birds'] = check_var_log_birds.get()
    config['logs']['udid'] = check_var_log_udid.get()
    config['logs']['events'] = check_var_log_events.get()
    config['logs']['errors'] = check_var_log_errors.get()
    config['logs']['battery'] = check_var_log_battery.get()
    config['logs']['rfid'] = check_var_log_rfid.get()

    # Attractive LEDs
    if scenario == 0 or scenario >= 2:

        config['attractiveleds'] = {}

        col = label_color_A.cget('text')
        col = col[1:-1].split(' ')

        config['attractiveleds']['red_a'] = col[0]
        config['attractiveleds']['green_a'] = col[1]
        config['attractiveleds']['blue_a'] = col[2]

        if scenario == 6:
            col = label_color_B.cget('text')
            col = col[1:-1].split(' ')

            config['attractiveleds']['red_b'] = col[0]
            config['attractiveleds']['green_b'] = col[1]
            config['attractiveleds']['blue_b'] = col[2]

        if scenario == 3 or scenario == 6:
            config['attractiveleds']['alt_delay'] = str(popupmenu_var_leds_alt_delay.get())

        config['attractiveleds']['on_hour'] = popupmenu_var_leds_on_hour.get()
        config['attractiveleds']['on_minute'] = popupmenu_var_leds_on_minute.get()

        if config['attractiveleds']['on_hour'] < config['time']['wakeup_hour'] or (config['attractiveleds']['on_hour'] == '00' and config['time']['wakeup_hour'] != '00'):
            config['attractiveleds']['on_hour'] = config['time']['wakeup_hour']
            config['attractiveleds']['on_minute'] = config['time']['wakeup_minute']
        elif config['attractiveleds']['on_hour'] == config['time']['wakeup_hour'] and config['attractiveleds']['on_minute'] < config['time']['wakeup_minute']:
            config['attractiveleds']['on_minute'] = config['time']['wakeup_minute']

        config['attractiveleds']['off_hour'] = popupmenu_var_leds_off_hour.get()
        config['attractiveleds']['off_minute'] = popupmenu_var_leds_off_minute.get()

        if config['attractiveleds']['off_hour'] > config['time']['sleep_hour'] or (config['attractiveleds']['off_hour'] == '00' and config['time']['sleep_hour'] != '00'):
            config['attractiveleds']['off_hour'] = config['time']['sleep_hour']
            config['attractiveleds']['off_minute'] = config['time']['sleep_minute']
        elif config['attractiveleds']['off_hour'] == config['time']['sleep_hour'] and config['attractiveleds']['off_minute'] > config['time']['sleep_minute']:
            config['attractiveleds']['off_minute'] = config['time']['sleep_minute']

        if scenario == 3:
            if radio_var_leds_pattern.get() == 'a':
                config['attractiveleds']['pattern'] = '0'
                config['attractiveleds']['pattern_percent'] = str(popupmenu_var_pattern_all_percent.get())
            elif radio_var_leds_pattern.get() == 'lr':
                config['attractiveleds']['pattern'] = '1'
            elif radio_var_leds_pattern.get() == 'tb':
                config['attractiveleds']['pattern'] = '2'
            elif radio_var_leds_pattern.get() == 'o':
                config['attractiveleds']['pattern'] = '3'

    # Pit tags
    if scenario > 2:

        pass

    # Door
    config['door'] = {}
    config['door']['open_hour'] = popupmenu_var_door_open_hour.get()
    config['door']['open_minute'] = popupmenu_var_door_open_minute.get()

    if config['door']['open_hour'] < config['time']['wakeup_hour'] or (config['door']['open_hour'] == '00' and config['time']['wakeup_hour'] != '00'):
        config['door']['open_hour'] = config['time']['wakeup_hour']
        config['door']['open_minute'] = config['time']['wakeup_minute']
    elif config['door']['open_hour'] == config['time']['wakeup_hour'] and config['door']['open_minute'] < config['time']['wakeup_minute']:
        config['door']['open_minute'] = config['time']['wakeup_minute']

    config['door']['close_hour'] = popupmenu_var_door_close_hour.get()
    config['door']['close_minute'] = popupmenu_var_door_close_minute.get()

    if config['door']['close_hour'] > config['time']['sleep_hour'] or (config['door']['close_hour'] == '00' and config['time']['sleep_hour'] != '00'):
        config['door']['close_hour'] = config['time']['sleep_hour']
        config['door']['close_minute'] = config['time']['sleep_minute']
    elif config['door']['close_hour'] == config['time']['sleep_hour'] and config['door']['close_minute'] > config['time']['sleep_minute']:
        config['door']['close_minute'] = config['time']['sleep_minute']

    config['door']['remain_open'] = check_var_door_remain_open.get()

    config['door']['open_delay'] = str(popupmenu_var_door_open_delay.get())
    config['door']['close_delay'] = str(popupmenu_var_door_close_delay.get())

    # Servomotor
    if int(entry_var_servo_close_position.get()) < 600:
        config['door']['close_position'] = '600'
    else:
        config['door']['close_position'] = entry_var_servo_close_position.get()

    if int(entry_var_servo_open_position.get()) > 2400:
        config['door']['open_position'] = '2400'
    else:
        config['door']['open_position'] = entry_var_servo_open_position.get()

    config['door']['closing_speed'] = entry_var_servo_close_speed.get()
    config['door']['opening_speed'] = entry_var_servo_open_speed.get()

    # Door habituation
    config['door']['habituation'] = str(popupmenu_var_door_habit_percent.get())

    # Reward
    config['reward'] = {}
    config['reward']['enable'] = check_var_reward_enable.get()

    if config['reward']['enable'] == '1':
        config['reward']['timeout'] = str(popupmenu_var_reward_timeout.get())

    if scenario > 2 and scenario < 8:
        config['reward']['probability'] = str(popupmenu_var_reward_probability.get())

    # Timeouts
    config['timeouts'] = {}
    config['timeouts']['unique_visit'] = str(popupmenu_var_unique_visit_timeout.get())

    # Punishment
    config['punishment'] = {}
    config['punishment']['delay'] = str(popupmenu_var_punishment_delay.get())
    if scenario == 2:
        config['punishment']['proba_threshold'] = str(popupmenu_var_probability_threshold.get())

    # Check
    config['check'] = {}
    config['check']['food_level'] = check_var_food_level.get()

    # Version
    config['version'] = {}
    config['version']['major'] = str(version['major'])
    config['version']['minor'] = str(version['minor'])
    config['version']['patch'] = str(version['patch'])

    # Date
    current_date = datetime.datetime.now()

    config['gendate'] = {}
    config['gendate']['year'] = str(current_date.year)
    config['gendate']['month'] = str(current_date.month)
    config['gendate']['day'] = str(current_date.day)
    config['gendate']['hour'] = str(current_date.hour)
    config['gendate']['minute'] = str(current_date.minute)
    config['gendate']['second'] = str(current_date.second)

    return config


def populate_ui(config):

    # Site ID
    popupmenu_var_site_name.set(config['siteid']['zone'][0:2])
    popupmenu_var_site_number.set(config['siteid']['zone'][2:])

    # WakeUp
    popupmenu_var_wake_up_hour.set(config['time']['wakeup_hour'])
    popupmenu_var_wake_up_minute.set(config['time']['wakeup_minute'])
    # Sleep
    popupmenu_var_sleep_hour.set(config['time']['sleep_hour'])
    popupmenu_var_sleep_minute.set(config['time']['sleep_minute'])

    # Scenario
    popupmenu_var_scenario.set(config['scenario']['num'] + ' - ' + config['scenario']['title'])

    scenario = int(config['scenario']['num'])

    # Logs
    popupmenu_var_log_file_separator.set(config['logs']['separator'])
    check_var_log_birds.set(config['logs']['birds'])
    check_var_log_udid.set(config['logs']['udid'])
    check_var_log_events.set(config['logs']['events'])
    check_var_log_errors.set(config['logs']['errors'])
    check_var_log_battery.set(config['logs']['battery'])
    check_var_log_rfid.set(config['logs']['rfid'])

    # Pit tags
    if 'pittags' in config:
        pass

    # Attractive LEDs
    if 'attractiveleds' in config:

        label_var_colorA.set('[{} {} {}]'.format(config['attractiveleds']['red_a'],
                                                 config['attractiveleds']['green_a'],
                                                 config['attractiveleds']['blue_a']))

        canvas_color_A.config(background='#{:02X}{:02X}{:02X}'.format(int(config['attractiveleds']['red_a']),
                                                                      int(config['attractiveleds']['green_a']),
                                                                      int(config['attractiveleds']['blue_a'])))

        if 'red_b' in config['attractiveleds']:
            label_var_colorB.set('[{} {} {}]'.format(config['attractiveleds']['red_b'],
                                                     config['attractiveleds']['green_b'],
                                                     config['attractiveleds']['blue_b']))

            canvas_color_B.config(background='#{:02X}{:02X}{:02X}'.format(int(config['attractiveleds']['red_b']),
                                                                          int(config['attractiveleds']['green_b']),
                                                                          int(config['attractiveleds']['blue_b'])))
        else:
            label_var_colorB.set('[0 0 0]')
            canvas_color_B.config(background='black')


        if 'alt_delay' in config['attractiveleds']:
            popupmenu_var_leds_alt_delay.set(int(config['attractiveleds']['alt_delay']))

        popupmenu_var_leds_on_hour.set(config['attractiveleds']['on_hour'])
        popupmenu_var_leds_on_minute.set(config['attractiveleds']['on_minute'])

        popupmenu_var_leds_off_hour.set(config['attractiveleds']['off_hour'])
        popupmenu_var_leds_off_minute.set(config['attractiveleds']['off_minute'])

        radio_var_leds_pattern.set(None)

        if scenario == 3:
            if config['attractiveleds']['pattern'] == '0':
                radio_var_leds_pattern.set('a')
            elif config['attractiveleds']['pattern'] == '1':
                radio_var_leds_pattern.set('lr')
            elif config['attractiveleds']['pattern'] == '2':
                radio_var_leds_pattern.set('tb')
            elif config['attractiveleds']['pattern'] == '3':
                radio_var_leds_pattern.set('o')

            if 'pattern_percent' in config['attractiveleds']:
                popupmenu_var_pattern_all_percent.set(int(config['attractiveleds']['pattern_percent']))
            else:
                popupmenu_var_pattern_all_percent.set('0')

    else:

        radio_var_leds_pattern.set(None)
        popupmenu_var_pattern_all_percent.set('0')
        popupmenu_var_leds_alt_delay.set(1)

    # Door
    popupmenu_var_door_open_hour.set(config['door']['open_hour'])
    popupmenu_var_door_open_minute.set(config['door']['open_minute'])

    popupmenu_var_door_close_hour.set(config['door']['close_hour'])
    popupmenu_var_door_close_minute.set(config['door']['close_minute'])

    check_var_door_remain_open.set(config['door']['remain_open'])

    popupmenu_var_door_open_delay.set(int(config['door']['open_delay']))
    popupmenu_var_door_close_delay.set(int(config['door']['close_delay']))

    # Servomotor
    entry_var_servo_close_position.set(config['door']['close_position'])
    entry_var_servo_open_position.set(config['door']['open_position'])

    entry_var_servo_close_speed.set(config['door']['closing_speed'])
    entry_var_servo_open_speed.set(config['door']['opening_speed'])

    # Door habituation
    if 'habituation' in config['door']:
        popupmenu_var_door_habit_percent.set(int(config['door']['habituation']))
    else:
        popupmenu_var_door_habit_percent.set(0)

    # Reward
    if 'reward' in config:
        check_var_reward_enable.set(config['reward']['enable'])
        if config['reward']['enable'] == '1':
            popupmenu_var_reward_timeout.set(int(config['reward']['timeout']))

        if 'probability' in config['reward']:
            popupmenu_var_reward_probability.set(int(config['reward']['probability']))
        else:
            popupmenu_var_reward_probability.set(100)

    # Timeouts
    if 'timeouts' in config:
        if 'unique_visit' in config['timeouts']:
            popupmenu_var_unique_visit_timeout.set(int(config['timeouts']['unique_visit']))
        else:
            popupmenu_var_unique_visit_timeout.set(0)

    # Punishment
    if 'punishment' in config:
        if 'delay' in config['punishment']:
            popupmenu_var_punishment_delay.set(int(config['punishment']['delay']))
        else:
            popupmenu_var_punishment_delay.set(0)

        if 'proba_threshold' in config['punishment']:
            popupmenu_var_probability_threshold.set(int(config['punishment']['proba_threshold']))
        else:
            popupmenu_var_probability_threshold.set(0)

    # Check
    if 'food_level' in config['check']:
        check_var_food_level.set(config['check']['food_level'])
    else:
        check_var_food_level.set('0')


def update_servoMove_time():

    label_closing_time.config(text='{:.3f}'.format((int(entry_var_servo_open_position.get())-int(entry_var_servo_close_position.get()))/int(entry_var_servo_close_speed.get())*default['ServoMsStep']/1000))
    label_opening_time.config(text='{:.3f}'.format((int(entry_var_servo_open_position.get())-int(entry_var_servo_close_position.get()))/int(entry_var_servo_open_speed.get())*default['ServoMsStep']/1000))
    label_guillotine_timeout.config(text='{:.3f}'.format((int(entry_var_servo_open_position.get())-int(entry_var_servo_close_position.get()))/int(entry_var_servo_close_speed.get())*default['ServoMsStep']/1000+0.5))

    preview_ini_file(None)


def set_attract_leds_color(a_or_b):

    color = askcolor()

    if a_or_b == 'A':
        canvas_color_A.config(background=color[1])
        label_var_colorA.set('[{} {} {}]'.format(int(color[0][0]), int(color[0][1]), int(color[0][2])))
    else:
        canvas_color_B.config(background=color[1])
        label_var_colorB.set('[{} {} {}]'.format(int(color[0][0]), int(color[0][1]), int(color[0][2])))

    preview_ini_file(None)


def attractive_led_pattern(typ):

    scenario = popupmenu_var_scenario.get()
    idx = scenario.index(' - ')

    scenario = int(scenario[0:idx])

    if scenario != 3:
        return

    popupmenu_var_pattern_all_percent.set(0)

    check_button_pit_tags_1.config(text='')
    check_button_pit_tags_2.config(text='')
    check_button_pit_tags_3.config(text='')
    check_button_pit_tags_4.config(text='')

    if typ == 'a':

        popupmenu_var_pattern_all_percent.set(25)

    elif typ == 'lr':

        check_button_pit_tags_1.config(text='Left')
        check_button_pit_tags_2.config(text='Right')

    elif typ == 'tb':

        check_button_pit_tags_1.config(text='Top')
        check_button_pit_tags_2.config(text='Bottom')

    elif typ == 'o':

        check_button_pit_tags_1.config(text='LED 1')
        check_button_pit_tags_2.config(text='LED 2')
        check_button_pit_tags_3.config(text='LED 3')
        check_button_pit_tags_4.config(text='LED 4')

    preview_ini_file(None)


def of_read_ini(filename):

    config = configparser.ConfigParser()

    config.read(filename)

    return config


def of_write_ini(pathname, filename):

    config = get_data_from_ui()

    filepath = os.path.join(pathname, filename)

    with open(filepath, 'w') as configfile:
        config.write(configfile)


# https://stackoverflow.com/questions/3352918/how-to-center-a-window-on-the-screen-in-tkinter#10018670
def center(win):
    """
    centers a tkinter window
    :param win: the root or Toplevel window to center
    """
    win.update_idletasks()
    width = win.winfo_width()
    frm_width = win.winfo_rootx() - win.winfo_x()
    win_width = width + 2 * frm_width
    height = win.winfo_height()
    titlebar_height = win.winfo_rooty() - win.winfo_y()
    win_height = height + titlebar_height + frm_width
    x = win.winfo_screenwidth() // 2 - win_width // 2
    y = win.winfo_screenheight() // 2 - win_height // 2
    win.geometry('{}x{}+{}+{}'.format(width, height, x, y))
    win.deiconify()


if __name__ == '__main__':

    if sys.platform == 'darwin':
        is_mac = 1
    else:
        is_mac = 0

    window_size = [1000, 750]

    # Create invisible window
    root = Tk()
    root.title('OpenFeeder - Configuration tool - v{}.{}.{}'.format(version['major'], version['minor'], version['patch']))
    root.resizable(False, False)
    root.geometry('{}x{}+0+0'.format(window_size[0], window_size[1]))

    if is_mac:
        root.config(bg='white')

    of_font_bold = Font(font='TkDefaultFont')
    of_font_bold.config(weight='bold')

    # Center window
    center(root)

    ui_sketch_factor = window_size[0]/240

    pathname = os.path.dirname(__file__)
    pathname = os.path.abspath(pathname)
    filepath = os.path.join(pathname, 'sites.txt')

    sites_name = []
    if os.path.exists(filepath):

        file = open(filepath, 'r')

        while True:

            line = file.readline()

            if not line:
                break

            idx = line.find(',')
            sites_name.append(line[0:idx])

        file.close()

    hours = []
    for i in range(0, 24):
        hours.append('{:02d}'.format(i))

    minutes = []
    for i in range(0, 60, 5):
        minutes.append('{:02d}'.format(i))

    ui_site_group_pos = [5, 5, 50, 5, 2, 5]
    ui_wake_up_group_pos = [5, 15, 50, 5, 2, 5]
    ui_sleep_group_pos = [5, 25, 50, 5, 2, 5]
    ui_scenario_group_pos = [5, 35, 35, 5, 2, 5]
    ui_log_group_pos = [5, 45, 50, 5, 2, 5]
    ui_pit_tag_group_pos = [5, 73, 80, 5, 2, 95]
    uiLedsGroupPos = [48, 5, 50, 5, 2, 5]
    uiDoorGroupPos = [95, 5, 50, 5, 2, 5]
    uiServoGroupPos = [95, 48, 50, 5, 2, 5]
    uiDoorHabitGroupPos = [95, 88, 50, 5, 2, 5]
    uiRewardGroupPos = [95, 99, 48, 5, 2, 5]
    uiTimeoutsGroupPos = [95, 124, 48, 5, 2, 5]
    uiPunishmentGroupPos = [95, 142, 50, 5, 2, 5]
    uiCheckGroupPos = [95, 161, 50, 5, 2, 5]
    uiPreviewGroupPos = [145+5*is_mac, 5, 50, 5, 2, 148]
    uiButtonGroupPos = [145+5*is_mac, 160, 50, 5, 2, 5]

    # Site ID
    label_site_id = Label(root, text='Site ID', anchor='w', font=of_font_bold)
    label_site_id.place(x=ui_site_group_pos[0]*ui_sketch_factor, y=ui_site_group_pos[1]*ui_sketch_factor, width=ui_site_group_pos[2]*ui_sketch_factor, height=ui_site_group_pos[3]*ui_sketch_factor)
    xPos = ui_site_group_pos[0]+ui_site_group_pos[4]
    yPos = ui_site_group_pos[1]+ui_site_group_pos[5]

    popupmenu_var_site_name = StringVar(root)
    popupmenu_var_site_name.set(sites_name[0])
    popupMenu = OptionMenu(root, popupmenu_var_site_name, *sites_name)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(15+5*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos += 15+5*is_mac

    sites_number = []
    for i in range(1, 21):
        sites_number.append('{:02d}'.format(i))
    popupmenu_var_site_number = StringVar(root)
    popupmenu_var_site_number.set(sites_number[0])
    popupMenu = OptionMenu(root, popupmenu_var_site_number, *sites_number,
                           command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(15+5*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    # Wake up time
    label_wake_up_time = Label(root, text='Wake up time', anchor='w', font=of_font_bold)
    label_wake_up_time.place(x=ui_wake_up_group_pos[0]*ui_sketch_factor, y=ui_wake_up_group_pos[1]*ui_sketch_factor, width=ui_wake_up_group_pos[2]*ui_sketch_factor, height=ui_wake_up_group_pos[3]*ui_sketch_factor)
    xPos = ui_wake_up_group_pos[0]+ui_wake_up_group_pos[4]
    yPos = ui_wake_up_group_pos[1]+ui_wake_up_group_pos[5]

    popupmenu_var_wake_up_hour = StringVar(root)
    popupmenu_var_wake_up_hour.set(hours[0])
    popupMenu = OptionMenu(root, popupmenu_var_wake_up_hour, *hours, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos += 12+8*is_mac
    label = Label(root, text=':')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=5*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 5

    popupmenu_var_wake_up_minute = StringVar(root)
    popupmenu_var_wake_up_minute.set(minutes[0])
    popupMenu = OptionMenu(root, popupmenu_var_wake_up_minute, *minutes, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    # Sleep time
    label_sleep_time = Label(root, text='Sleep time', anchor='w', font=of_font_bold)
    label_sleep_time.place(x=ui_sleep_group_pos[0]*ui_sketch_factor, y=ui_sleep_group_pos[1]*ui_sketch_factor, width=ui_sleep_group_pos[2]*ui_sketch_factor, height=ui_sleep_group_pos[3]*ui_sketch_factor)
    xPos = ui_sleep_group_pos[0]+ui_sleep_group_pos[4]
    yPos = ui_sleep_group_pos[1]+ui_sleep_group_pos[5]

    popupmenu_var_sleep_hour = StringVar(root)
    popupmenu_var_sleep_hour.set(hours[0])
    popupMenu = OptionMenu(root, popupmenu_var_sleep_hour, *hours, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos += 12+8*is_mac
    label = Label(root, text=':')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=5*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 5

    popupmenu_var_sleep_minute = StringVar(root)
    popupmenu_var_sleep_minute.set(minutes[0])
    popupMenu = OptionMenu(root, popupmenu_var_sleep_minute, *minutes, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    # Scenario
    label_scenario = Label(root, text='Scenario', anchor='w', font=of_font_bold)
    label_scenario.place(x=ui_scenario_group_pos[0]*ui_sketch_factor, y=ui_scenario_group_pos[1]*ui_sketch_factor, width=ui_scenario_group_pos[2]*ui_sketch_factor, height=ui_scenario_group_pos[3]*ui_sketch_factor)
    xPos = ui_scenario_group_pos[0]+ui_scenario_group_pos[4]
    yPos = ui_scenario_group_pos[1]+ui_scenario_group_pos[5]

    popupmenu_var_scenario = StringVar(root)
    choices = {'0 - None',
               '1 - OpenBar',
               '2 - DoorHabituation',
               '3 - Go-NoGo',
               '4 - LongTermSpatialMemory',
               '5 - WorkingSpatialMemory',
               '6 - ColorAssociativeLearning',
               '7 - RiskAversion',
               '8 - PatchProbability'}
    popupmenu_var_scenario.set('0 - None')
    popupMenu = OptionMenu(root, popupmenu_var_scenario, *sorted(choices),
                           command=set_scenario)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(ui_scenario_group_pos[2]+8)*ui_sketch_factor, height=5*ui_sketch_factor)

    # Log File
    label_log_file = Label(root, text='Logs', anchor='w', font=of_font_bold)
    label_log_file.place(x=ui_log_group_pos[0]*ui_sketch_factor, y=ui_log_group_pos[1]*ui_sketch_factor, width=ui_log_group_pos[2]*ui_sketch_factor, height=ui_log_group_pos[3]*ui_sketch_factor)
    xPos = ui_log_group_pos[0]+ui_log_group_pos[4]
    yPos = ui_log_group_pos[1]+ui_log_group_pos[5]
    label_log_file_separator = Label(root, text='Data separator', anchor='w')
    label_log_file_separator.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 25

    popupmenu_var_log_file_separator = StringVar(root)
    separators = [',', ';']
    popupmenu_var_log_file_separator.set(separators[0])
    popupMenu = OptionMenu(root, popupmenu_var_log_file_separator, *separators, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=10*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos = ui_log_group_pos[0]+ui_log_group_pos[4]
    yPos += 6
    check_var_log_birds = StringVar()
    check_var_log_udid = StringVar()
    check_var_log_events = StringVar()
    check_var_log_errors = StringVar()
    check_var_log_battery = StringVar()
    check_var_log_rfid = StringVar()

    check_button_log_birds = Checkbutton(root, text='Birds', anchor='w', \
                                         variable=check_var_log_birds, \
                                         onvalue='1', offvalue='0', command=partial(preview_ini_file, None))
    check_button_log_birds.deselect()
    check_button_log_birds.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 13
    check_button_log_udid = Checkbutton(root, text='UDID', anchor='w', \
                                         variable=check_var_log_udid, \
                                         onvalue='1', offvalue='0', command=partial(preview_ini_file, None))
    check_button_log_udid.deselect()
    check_button_log_udid.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 13
    check_button_log_events = Checkbutton(root, text='Events', anchor='w', \
                                         variable=check_var_log_events, \
                                         onvalue='1', offvalue='0', command=partial(preview_ini_file, None))
    check_button_log_events.deselect()
    check_button_log_events.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos = ui_log_group_pos[0]+ui_log_group_pos[4]
    yPos += 6
    check_button_log_errors = Checkbutton(root, text='Errors', anchor='w', \
                                         variable=check_var_log_errors, \
                                         onvalue='1', offvalue='0', command=partial(preview_ini_file, None))
    check_button_log_errors.deselect()
    check_button_log_errors.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 13
    check_button_log_battery = Checkbutton(root, text='Battery', anchor='w', \
                                         variable=check_var_log_battery, \
                                         onvalue='1', offvalue='0', command=partial(preview_ini_file, None))
    check_button_log_battery.deselect()
    check_button_log_battery.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 13
    check_button_log_rfid = Checkbutton(root, text='RFID', anchor='w', \
                                         variable=check_var_log_rfid, \
                                         onvalue='1', offvalue='0', command=partial(preview_ini_file, None))
    check_button_log_rfid.deselect()
    check_button_log_rfid.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)

    # Pit Tags
    label_pit_tags = Label(root, text='PIT tags', anchor='w', font=of_font_bold)
    label_pit_tags.place(x=ui_pit_tag_group_pos[0]*ui_sketch_factor, y=(ui_pit_tag_group_pos[1]-5)*ui_sketch_factor, width=ui_pit_tag_group_pos[2]*ui_sketch_factor, height=ui_pit_tag_group_pos[3]*ui_sketch_factor)

    xPos = ui_pit_tag_group_pos[0]
    yPos = ui_pit_tag_group_pos[1]

    check_value_pit_tags_1 = IntVar()
    check_value_pit_tags_2 = IntVar()
    check_value_pit_tags_3 = IntVar()
    check_value_pit_tags_4 = IntVar()

    check_button_pit_tags_1 = Checkbutton(root, text='', anchor='w', onvalue=1,
                                          offvalue=0,
                                          variable=check_value_pit_tags_1, command=partial(preview_ini_file, None))
    check_button_pit_tags_1.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=40*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 2
    yPos += 5
    text_pit_tag_1 = Text(root)
    text_pit_tag_1.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(ui_pit_tag_group_pos[2]-25)/2*ui_sketch_factor, height=(ui_pit_tag_group_pos[5]/2)*ui_sketch_factor)

    xPos -= 2
    yPos = ui_pit_tag_group_pos[1]+ui_pit_tag_group_pos[5]/2+4
    check_button_pit_tags_3 = Checkbutton(root, text='', anchor='w', onvalue=1,
                                          offvalue=0,
                                          variable=check_value_pit_tags_3, command=partial(preview_ini_file, None))
    check_button_pit_tags_3.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=40*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 2
    yPos += 5
    text_pit_tag_3 = Text(root)
    text_pit_tag_3.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(ui_pit_tag_group_pos[2]-25)/2*ui_sketch_factor, height=(ui_pit_tag_group_pos[5]/2)*ui_sketch_factor)

    xPos += -2 + (ui_pit_tag_group_pos[2]+25)/2
    yPos = ui_pit_tag_group_pos[1]
    check_button_pit_tags_2 = Checkbutton(root, text='', anchor='w', onvalue=1,
                                          offvalue=0,
                                          variable=check_value_pit_tags_2, command=partial(preview_ini_file, None))
    check_button_pit_tags_2.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=15*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 2
    yPos += 5
    text_pit_tag_2 = Text(root)
    text_pit_tag_2.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(ui_pit_tag_group_pos[2]-25)/2*ui_sketch_factor, height=(ui_pit_tag_group_pos[5]/2)*ui_sketch_factor)

    xPos = ui_pit_tag_group_pos[0] + (ui_pit_tag_group_pos[2]+25)/2
    yPos = ui_pit_tag_group_pos[1]+ui_pit_tag_group_pos[5]/2+4
    check_button_pit_tags_4 = Checkbutton(root, text='', anchor='w', onvalue=1,
                                          offvalue=0,
                                          variable=check_value_pit_tags_4, command=partial(preview_ini_file, None))
    check_button_pit_tags_4.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=40*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 2
    yPos += 5
    text_pit_tag_4 = Text(root)
    text_pit_tag_4.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(ui_pit_tag_group_pos[2]-25)/2*ui_sketch_factor, height=(ui_pit_tag_group_pos[5]/2)*ui_sketch_factor)

    xPos = ui_pit_tag_group_pos[0] + ui_pit_tag_group_pos[2]/2 - 5.5
    yPos = ui_pit_tag_group_pos[1]+40

    button_load_pit_tags = Button(root, text='Load')
    button_load_pit_tags.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=15*ui_sketch_factor, height=5*ui_sketch_factor)

    # Attractive LEDs color
    label_leds = Label(root, text='Attractive LEDs', anchor='w', font=of_font_bold)
    label_leds.place(x=uiLedsGroupPos[0]*ui_sketch_factor, y=uiLedsGroupPos[1]*ui_sketch_factor, width=uiLedsGroupPos[2]*ui_sketch_factor, height=uiLedsGroupPos[3]*ui_sketch_factor)

    xPos = uiLedsGroupPos[0]+uiLedsGroupPos[4]
    yPos = uiLedsGroupPos[1]+uiLedsGroupPos[5]
    button_leds_color_A = Button(root, text='Set color A', command=partial(set_attract_leds_color, 'A'))
    button_leds_color_A.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    yPos += 5
    label_var_colorA = StringVar()
    label_var_colorA.set('[0 0 0]')
    label_color_A = Label(root, textvariable=label_var_colorA)
    label_color_A.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=uiLedsGroupPos[3]*ui_sketch_factor)

    xPos += 30
    canvas_color_A = Canvas(root, width=8, height=8, background='black')
    canvas_color_A.place(x=xPos*ui_sketch_factor, y=(yPos-3)*ui_sketch_factor, width=8*ui_sketch_factor, height=8*ui_sketch_factor)

    xPos = uiLedsGroupPos[0]+uiLedsGroupPos[4]
    yPos += 6

    button_leds_color_B = Button(root, text='Set color B', command=partial(set_attract_leds_color, 'B'))
    button_leds_color_B.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    yPos += 5
    label_var_colorB = StringVar()
    label_var_colorB.set('[0 0 0]')
    label_color_B = Label(root, textvariable=label_var_colorB)
    label_color_B.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=uiLedsGroupPos[3]*ui_sketch_factor)

    xPos += 30
    canvas_color_B = Canvas(root, width=8, height=8, background='black')
    canvas_color_B.place(x=xPos*ui_sketch_factor, y=(yPos-3)*ui_sketch_factor, width=8*ui_sketch_factor, height=8*ui_sketch_factor)

    xPos = uiLedsGroupPos[0]+uiLedsGroupPos[4]
    yPos += 5
    label_pattern = Label(root, text='Pattern', anchor='w')
    label_pattern.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=15*ui_sketch_factor, height=uiLedsGroupPos[3]*ui_sketch_factor)

    xPos += 2
    yPos += 4

    radio_var_leds_pattern = StringVar()
    radio_var_leds_pattern.set(None)

    radio_button_pattern_all = Radiobutton(root, text='All', anchor='w',
                                           command=partial(attractive_led_pattern, 'a'),
                                           variable=radio_var_leds_pattern,
                                           value='a')
    radio_button_pattern_all.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos += 12
    label = Label(root, text='% on', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 8

    popupmenu_var_pattern_all_percent = IntVar(root)
    percents = []
    for n in range(0, 105, 5):
        percents.append(n)
    popupmenu_var_pattern_all_percent.set(percents[0])
    popupMenu = OptionMenu(root, popupmenu_var_pattern_all_percent, *percents, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=15*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos = uiLedsGroupPos[0]+uiLedsGroupPos[4]
    xPos += 2
    yPos += 6
    radio_button_pattern_lr = Radiobutton(root, text='L/R', anchor='w',
                                          command=partial(attractive_led_pattern, 'lr'),
                                          variable=radio_var_leds_pattern,
                                          value='lr')
    radio_button_pattern_lr.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos += 12
    radio_button_pattern_tb = Radiobutton(root, text='T/B', anchor='w',
                                          command=partial(attractive_led_pattern, 'tb'),
                                          variable=radio_var_leds_pattern,
                                          value='tb')
    radio_button_pattern_tb.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos += 12
    radio_button_pattern_one = Radiobutton(root, text='One', anchor='w',
                                           command=partial(attractive_led_pattern, 'o'),
                                           variable=radio_var_leds_pattern,
                                           value='o')
    radio_button_pattern_one.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos = uiLedsGroupPos[0]+uiLedsGroupPos[4]
    yPos += 8
    label = Label(root, text='Alt. delay (s)', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=17*ui_sketch_factor, height=uiLedsGroupPos[3]*ui_sketch_factor)
    xPos += 18

    popupmenu_var_leds_alt_delay = IntVar(root)
    delay = []
    for n in range(1, 11):
        delay.append(n)
    for n in range(20, 40, 10):
        delay.append(n)
    delay.append(60)
    popupmenu_var_leds_alt_delay.set(delay[0])
    popupMenu = OptionMenu(root, popupmenu_var_leds_alt_delay, *delay, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=15*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos = uiLedsGroupPos[0]+uiLedsGroupPos[4]
    yPos += 8
    label = Label(root, text='On', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=17*ui_sketch_factor, height=uiLedsGroupPos[3]*ui_sketch_factor)

    xPos += 10

    popupmenu_var_leds_on_hour = StringVar(root)
    popupmenu_var_leds_on_hour.set(hours[0])
    popupMenu = OptionMenu(root, popupmenu_var_leds_on_hour, *hours, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos += 12+8*is_mac
    label = Label(root, text=':')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=5*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 5

    popupmenu_var_leds_on_minute = StringVar(root)
    popupmenu_var_leds_on_minute.set(minutes[0])
    popupMenu = OptionMenu(root, popupmenu_var_leds_on_minute, *minutes, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos = uiLedsGroupPos[0]+uiLedsGroupPos[4]
    yPos += 6
    label = Label(root, text='Off', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=17*ui_sketch_factor, height=uiLedsGroupPos[3]*ui_sketch_factor)

    xPos += 10

    popupmenu_var_leds_off_hour = StringVar(root)
    popupmenu_var_leds_off_hour.set(hours[0])
    popupMenu = OptionMenu(root, popupmenu_var_leds_off_hour, *hours, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos += 12+8*is_mac
    label = Label(root, text=':')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=5*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 5

    popupmenu_var_leds_off_minute = StringVar(root)
    popupmenu_var_leds_off_minute.set(minutes[0])
    popupMenu = OptionMenu(root, popupmenu_var_leds_off_minute, *minutes, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    # Door
    label_door = Label(root, text='Door', anchor='w', font=of_font_bold)
    label_door.place(x=uiDoorGroupPos[0]*ui_sketch_factor, y=uiDoorGroupPos[1]*ui_sketch_factor, width=uiDoorGroupPos[2]*ui_sketch_factor, height=uiDoorGroupPos[3]*ui_sketch_factor)

    xPos = uiDoorGroupPos[0]+uiDoorGroupPos[4]
    yPos = uiDoorGroupPos[1]+uiDoorGroupPos[5]

    label = Label(root, text='Open', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=17*ui_sketch_factor, height=uiLedsGroupPos[3]*ui_sketch_factor)

    xPos += 10

    popupmenu_var_door_open_hour = StringVar(root)
    popupmenu_var_door_open_hour.set(hours[0])
    popupMenu = OptionMenu(root, popupmenu_var_door_open_hour, *hours, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos += 12+8*is_mac
    label = Label(root, text=':')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=5*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 5

    popupmenu_var_door_open_minute = StringVar(root)
    popupmenu_var_door_open_minute.set(minutes[0])
    popupMenu = OptionMenu(root, popupmenu_var_door_open_minute, *minutes, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos = uiDoorGroupPos[0]+uiDoorGroupPos[4]
    yPos += 6
    label = Label(root, text='Close', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=17*ui_sketch_factor, height=uiLedsGroupPos[3]*ui_sketch_factor)

    xPos += 10

    popupmenu_var_door_close_hour = StringVar(root)
    popupmenu_var_door_close_hour.set(hours[0])
    popupMenu = OptionMenu(root, popupmenu_var_door_close_hour, *hours, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos += 12+8*is_mac
    label = Label(root, text=':')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=5*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 5

    popupmenu_var_door_close_minute = StringVar(root)
    popupmenu_var_door_close_minute.set(minutes[0])
    popupMenu = OptionMenu(root, popupmenu_var_door_close_minute, *minutes, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos = uiDoorGroupPos[0]+uiDoorGroupPos[4]
    yPos += 8

    check_var_door_remain_open = StringVar()
    check_door_remain_open = Checkbutton(root, text='Remain open', anchor='w',
                                         variable=check_var_door_remain_open,
                                         onvalue='1', offvalue='0', command=partial(preview_ini_file, None))
    check_door_remain_open.deselect()
    check_door_remain_open.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos = uiDoorGroupPos[0]+uiDoorGroupPos[4]
    yPos += 8
    label = Label(root, text='Open delay (s)', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=20*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 30

    popupmenu_var_door_open_delay = IntVar(root)
    delay = []
    for n in range(0, 11):
        delay.append(n)
    for n in range(20, 40, 10):
        delay.append(n)
    delay.append(60)
    popupmenu_var_door_open_delay.set(delay[0])
    popupMenu = OptionMenu(root, popupmenu_var_door_open_delay, *delay, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos = uiDoorGroupPos[0]+uiDoorGroupPos[4]
    yPos += 8
    label = Label(root, text='Close delay (s)', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=20*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 30

    popupmenu_var_door_close_delay = IntVar(root)
    delay = []
    for n in range(0, 11):
        delay.append(n)
    for n in range(20, 40, 10):
        delay.append(n)
    delay.append(60)
    popupmenu_var_door_close_delay.set(delay[0])
    popupMenu = OptionMenu(root, popupmenu_var_door_close_delay, *delay, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    # Servomotor
    label = Label(root, text='Servomotor', anchor='w', font=of_font_bold)
    label.place(x=uiServoGroupPos[0]*ui_sketch_factor, y=uiServoGroupPos[1]*ui_sketch_factor, width=uiServoGroupPos[2]*ui_sketch_factor, height=uiServoGroupPos[3]*ui_sketch_factor)

    xPos = uiServoGroupPos[0]+uiServoGroupPos[4]
    yPos = uiServoGroupPos[1]+uiServoGroupPos[5]
    label = Label(root, text='Close position', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 25
    entry_var_servo_close_position = StringVar()
    entry_var_servo_close_position.set('{}'.format(default['ServoClosePosition']))
    entry = Entry(root, textvariable=entry_var_servo_close_position)
    entry.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=15*ui_sketch_factor, height=uiServoGroupPos[3]*ui_sketch_factor)
    xPos -= 25
    yPos += uiServoGroupPos[5]
    label = Label(root, text='Open position', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 25
    entry_var_servo_open_position = StringVar()
    entry_var_servo_open_position.set('{}'.format(default['ServoOpenPosition']))
    entry = Entry(root, textvariable=entry_var_servo_open_position)
    entry.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=15*ui_sketch_factor, height=uiServoGroupPos[3]*ui_sketch_factor)
    xPos -= 25
    yPos += uiServoGroupPos[5]
    label = Label(root, text='Close speed factor', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 25
    entry_var_servo_close_speed = StringVar()
    entry_var_servo_close_speed.set('{}'.format(default['ServoClosingSpeedFactor']))
    entry = Entry(root, textvariable=entry_var_servo_close_speed)
    entry.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=15*ui_sketch_factor, height=uiServoGroupPos[3]*ui_sketch_factor)
    xPos -= 25
    yPos += uiServoGroupPos[5]
    label = Label(root, text='Open speed factor', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 25
    entry_var_servo_open_speed = StringVar()
    entry_var_servo_open_speed.set('{}'.format(default['ServoOpeningSpeedFactor']))
    entry = Entry(root, textvariable=entry_var_servo_open_speed)
    entry.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=15*ui_sketch_factor, height=uiServoGroupPos[3]*ui_sketch_factor)
    xPos -= 25
    yPos += uiServoGroupPos[5]
    label = Label(root, text='Closing time (s)', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=50*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 25
    label_closing_time = Label(root, text='{:.3f}'.format((default['ServoOpenPosition']-default['ServoClosePosition'])/default['ServoClosingSpeedFactor']*default['ServoMsStep']/1000), anchor='w')
    label_closing_time.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos -= 25
    yPos += uiServoGroupPos[5]
    label = Label(root, text='Opening time (s)', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=50*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 25
    label_opening_time = Label(root, text='{:.3f}'.format((default['ServoOpenPosition']-default['ServoClosePosition'])/default['ServoOpeningSpeedFactor']*default['ServoMsStep']/1000), anchor='w')
    label_opening_time.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)

    # Door habituation
    label = Label(root, text='Door habituation', anchor='w', font=of_font_bold)
    label.place(x=uiDoorHabitGroupPos[0]*ui_sketch_factor, y=uiDoorHabitGroupPos[1]*ui_sketch_factor, width=uiDoorHabitGroupPos[2]*ui_sketch_factor, height=uiDoorHabitGroupPos[3]*ui_sketch_factor)

    xPos = uiDoorHabitGroupPos[0]+uiDoorHabitGroupPos[4]
    yPos = uiDoorHabitGroupPos[1]+uiDoorHabitGroupPos[5]

    label = Label(root, text='Open (%)', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 20

    popupmenu_var_door_habit_percent = IntVar(root)
    percent = []
    percent.append(0)
    for n in range(25, 80, 25):
        percent.append(n)
    percent.append(90)
    percent.append(100)
    popupmenu_var_door_habit_percent.set(percent[0])
    popupMenu = OptionMenu(root, popupmenu_var_door_habit_percent, *percent, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    # Reward
    label = Label(root, text='Reward', anchor='w', font=of_font_bold)
    label.place(x=uiRewardGroupPos[0]*ui_sketch_factor, y=uiRewardGroupPos[1]*ui_sketch_factor, width=uiRewardGroupPos[2]*ui_sketch_factor, height=uiRewardGroupPos[3]*ui_sketch_factor)

    xPos = uiRewardGroupPos[0]+uiRewardGroupPos[4]
    yPos = uiRewardGroupPos[1]+uiRewardGroupPos[5]

    check_var_reward_enable = StringVar()
    check_reward_enable = Checkbutton(root, text='Enable', anchor='w',
                                      variable=check_var_reward_enable,
                                      onvalue='1', offvalue='0', command=partial(preview_ini_file, None))
    check_reward_enable.deselect()
    check_reward_enable.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)

    yPos += 6
    label = Label(root, text='Timeout (s)', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 20

    popupmenu_var_reward_timeout = IntVar(root)
    timeout = []
    for n in range(0, 6):
        timeout.append(n)
    for n in range(10, 40, 10):
        timeout.append(n)
    timeout.append(60)
    popupmenu_var_reward_timeout.set(timeout[0])
    popupMenu = OptionMenu(root, popupmenu_var_reward_timeout, *timeout, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos -= 20
    yPos += 8
    label = Label(root, text='Probability (%)', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 20

    popupmenu_var_reward_probability = IntVar(root)
    probability = [100, 90, 80, 75, 70, 66, 60, 50, 40, 33, 30, 20, 10, 0]
    popupmenu_var_reward_probability.set(probability[0])
    popupMenu = OptionMenu(root, popupmenu_var_reward_probability, *probability, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    # Timeouts
    label = Label(root, text='Timeouts', anchor='w', font=of_font_bold)
    label.place(x=uiTimeoutsGroupPos[0]*ui_sketch_factor, y=uiTimeoutsGroupPos[1]*ui_sketch_factor, width=uiTimeoutsGroupPos[2]*ui_sketch_factor, height=uiTimeoutsGroupPos[3]*ui_sketch_factor)

    xPos = uiTimeoutsGroupPos[0]+uiTimeoutsGroupPos[4]
    yPos = uiTimeoutsGroupPos[1]+uiTimeoutsGroupPos[5]

    label = Label(root, text='Guillotine (s)', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=50*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 20
    label_guillotine_timeout = Label(root, text='{:.3f}'.format((default['ServoOpenPosition']-default['ServoClosePosition'])/default['ServoClosingSpeedFactor']*default['ServoMsStep']/1000+0.5), anchor='w')
    label_guillotine_timeout.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos = uiTimeoutsGroupPos[0]+uiTimeoutsGroupPos[4]
    yPos = uiTimeoutsGroupPos[1]+2*uiTimeoutsGroupPos[5]

    label = Label(root, text='Unique visit (s)', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 20

    popupmenu_var_unique_visit_timeout = IntVar(root)
    timeout = []
    for n in range(0, 6):
        timeout.append(n)
    for n in range(10, 40, 10):
        timeout.append(n)
    timeout.append(60)
    popupmenu_var_unique_visit_timeout.set(timeout[0])
    popupMenu = OptionMenu(root, popupmenu_var_unique_visit_timeout, *timeout, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    # Punishment
    label = Label(root, text='Punishment', anchor='w', font=of_font_bold)
    label.place(x=uiPunishmentGroupPos[0]*ui_sketch_factor, y=uiPunishmentGroupPos[1]*ui_sketch_factor, width=uiPunishmentGroupPos[2]*ui_sketch_factor, height=uiPunishmentGroupPos[3]*ui_sketch_factor)

    xPos = uiPunishmentGroupPos[0]+uiPunishmentGroupPos[4]
    yPos = uiPunishmentGroupPos[1]+uiPunishmentGroupPos[5]

    label = Label(root, text='Delay (s)', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 24

    popupmenu_var_punishment_delay = IntVar(root)
    delay = []
    for n in range(0, 35, 5):
        delay.append(n)
    popupmenu_var_punishment_delay.set(timeout[0])
    popupMenu = OptionMenu(root, popupmenu_var_punishment_delay, *delay, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    xPos = uiPunishmentGroupPos[0]+uiPunishmentGroupPos[4]
    yPos = uiPunishmentGroupPos[1]+uiPunishmentGroupPos[5]+7

    label = Label(root, text='Proba. thresh. (%)', anchor='w')
    label.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 24

    popupmenu_var_probability_threshold = IntVar(root)
    threshold = [0, 10, 20, 30, 33, 40, 50, 60, 66, 70, 75, 80, 90, 100]
    popupmenu_var_probability_threshold.set(threshold[0])
    popupMenu = OptionMenu(root, popupmenu_var_probability_threshold, *threshold, command=preview_ini_file)
    popupMenu.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=(12+8*is_mac)*ui_sketch_factor, height=5*ui_sketch_factor)

    # Check
    label = Label(root, text='Check', anchor='w', font=of_font_bold)
    label.place(x=uiCheckGroupPos[0]*ui_sketch_factor, y=uiCheckGroupPos[1]*ui_sketch_factor, width=uiCheckGroupPos[2]*ui_sketch_factor, height=uiCheckGroupPos[3]*ui_sketch_factor)

    xPos = uiCheckGroupPos[0]+uiCheckGroupPos[4]
    yPos = uiCheckGroupPos[1]+uiCheckGroupPos[5]

    check_var_food_level = StringVar()
    check_food_level = Checkbutton(root, text='Food level', anchor='w', \
                                         variable=check_var_food_level, \
                                         onvalue='1', offvalue='0', command=partial(preview_ini_file, None))
    check_food_level.deselect()
    check_food_level.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=30*ui_sketch_factor, height=5*ui_sketch_factor)

    # Load/Preview/Export buttons
    label = Label(root, text='INI file', anchor='w', font=of_font_bold)
    label.place(x=uiButtonGroupPos[0]*ui_sketch_factor, y=uiButtonGroupPos[1]*ui_sketch_factor, width=uiButtonGroupPos[2]*ui_sketch_factor, height=uiButtonGroupPos[3]*ui_sketch_factor)

    xPos = uiButtonGroupPos[0]+uiCheckGroupPos[4]
    yPos = uiButtonGroupPos[1]+uiButtonGroupPos[5]

    button_load_ini = Button(root, text='Load', command=load_ini_file)
    button_load_ini.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 30
    button_preview_ini = Button(root, text='Preview')
    button_preview_ini.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)
    xPos += 30
    button_export_ini = Button(root, text='Export', command=export_ini_file)
    button_export_ini.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=25*ui_sketch_factor, height=5*ui_sketch_factor)

    # Preview zone
    label = Label(root, text='Preview', anchor='w', font=of_font_bold)
    label.place(x=uiPreviewGroupPos[0]*ui_sketch_factor, y=uiPreviewGroupPos[1]*ui_sketch_factor, width=uiPreviewGroupPos[2]*ui_sketch_factor, height=uiPreviewGroupPos[3]*ui_sketch_factor)

    xPos = uiPreviewGroupPos[0]+uiPreviewGroupPos[4]
    yPos = uiPreviewGroupPos[1]+5

    text_preview = Text(root, state=DISABLED)
    text_preview.place(x=xPos*ui_sketch_factor, y=yPos*ui_sketch_factor, width=80*ui_sketch_factor, height=uiPreviewGroupPos[5]*ui_sketch_factor)

    set_default_time()

    root.mainloop()
