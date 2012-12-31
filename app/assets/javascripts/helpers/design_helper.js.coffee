window.DesignHelper =
  progressBar: (percentage, label)->
    result = if label then """<div class="text">#{ label }</div>""" else ''

    result += """
      <div class="progress_bar">
        <div
          class="percentage #{ if percentage >= 100 then 'complete' else ''}"
          style="width: #{ if percentage <= 100 then percentage else 100 }%"
        ></div>
      </div>
    """

    @safe result
