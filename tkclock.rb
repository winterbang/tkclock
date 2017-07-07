#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'observer'
require 'thread'
require 'tk'
require 'tkextlib/tkimg'
=begin
  ruby/tk简单的时钟
=end

class Clock
  #观察者模式
  include Observable
  def getPointAngle(time)
    #获取以y轴为线顺时针的角度,例如：3点钟则时针的角度为90度
    sec_angle = time.sec / 60.0 * 360
    min_angle = time.min / 60.0 * 360 + sec_angle / 360 / 60
    hour_angle = time.hour.divmod(12)[1] / 12.0 * 360 + min_angle / 360 * 30
    #转换成以xy轴的角度，例如3点钟，则时针的角度为0度，12点时针的角度为180度
    return [hour_angle, min_angle, sec_angle].collect do |x|
      x <= 90 ? 90 -x : 450 - x
    end
  end
  def run()
    #一秒种刷新一次界面
    loop do
      angles = self.getPointAngle(Time.now)
      changed()
      notify_observers(angles)
      sleep 1
    end
  end
end
class ClockView
  LENGTH_ARRAY = [40, 50, 70]
  def initialize(root)
    @cur_sec_line = nil
    @cur_hour_line = nil
    @cur_min_line = nil
    @canvas = TkCanvas.new(root)
    timg = TkPhotoImage.new('file' => './w.png')
    t = TkcImage.new(@canvas,100, 100, 'image' => timg)
    @canvas.pack('side' => 'left', 'fill' => 'both')
  end
  def update(angles)
    coords = Array.new
    #将角度转换成在界面上的坐标
    angles.to_a().each_with_index do |mangle, index|
      cy = Math.sin(mangle / 180 * Math::PI) * LENGTH_ARRAY[index]
      cx = Math.cos(mangle / 180  * Math::PI) * LENGTH_ARRAY[index]
      cx = cx + 100
      cy = 100 - cy
      coords[index] = [cx, cy]
    end
    @cur_sec_line != nil and @cur_sec_line.delete()
    @cur_min_line != nil and @cur_min_line.delete()
    @cur_hour_line != nil and @cur_hour_line.delete()
    hline = TkcLine.new(@canvas, 100, 100, coords[0][0], coords[0][1], "width" => "3")
    mline = TkcLine.new(@canvas, 100, 100, coords[1][0], coords[1][1], "width" => "2")
    sline = TkcLine.new(@canvas, 100, 100, coords[2][0], coords[2][1], "width" => "1")
    [hline, mline, sline].map { |aline|
      aline.fill 'yellow'
    }



    @cur_sec_line = sline
    @cur_hour_line = hline

    @cur_min_line = mline

  end

end



root = TkRoot.new do

  title '怀旧时钟'

  geometry "200x200+1000+80"
end

clock = Clock.new()

clock_view = ClockView.new(root)

clock.add_observer(clock_view)

Thread.new { clock.run

}

Tk.mainloop
