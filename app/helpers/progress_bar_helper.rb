# Helper to yield a progress bar component
module ProgressBarHelper
  # Yield the tags for a progress bar
  # @param processed [Integer] the number of items processed so far; accepts any object that responds to #to_i
  # @param total [Integer] the total number of items; accepts any object that responds to #to_i
  # @param status [String] an optional processing status message
  # @return [String] the tags representing the corresponding progress bar
  def progress_bar(processed, total, status = nil, errored = 0)
    numerator = errored.zero? ? processed : errored
    tag.div(class: ['status_badge', status]) do
      tag.div(message(numerator, total, status), class: ['status_text']).concat(
        tag.div(message(numerator, total, status), class: ['status_increment'], aria: { hidden: true },
                                                   style: "clip-path: inset(0 0 0 #{width(numerator, total, status)})")
      )
    end
  end

  # Caluclate the width of the progress bar as a percent
  # @param see ProgressBarHelper#progress_bar
  # @return [String] the progreess bar width at a percentage
  def width(processed, total, status = 'processing')
    return '100%' unless status == 'processing'

    "#{processed.to_i * 100 / total.to_i}%"
  rescue ZeroDivisionError
    '100%'
  end

  # Return the text for the progress bar
  # @param processed [] the number of items processed so far (numerator)
  # @param total [#to_i] the number of items total (denominator)
  # @param status[String] the state of the item represented by the progress bar
  # @return [String] A string like "12 queued" or "7 of 20 processed"
  def message(processed, total, status = nil)
    message = []
    message << "#{processed} of" if (processed != total) && (status != 'queued')
    message << total
    message << status
    message.compact.join(' ')
  end
end
