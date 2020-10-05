class RecurringFrequenciesController < ApplicationController

  def index
    @recurring_frequencies = RecurringFrequency.all.page(params[:page]).per(@per_page)
  end

  def new
    @recurring_frequency = RecurringFrequency.new
    respond_to do |format|
      format.js
    end
  end

  def create
    @recurring_frequency = RecurringFrequency.new(recurring_frequency_params)
    respond_to do |format|
      if @recurring_frequency.save
        format.js {
          flash[:notice] = 'Recurring Frequency has been created successfully'
          render :js => "window.location.href='#{settings_path}'"
        }
      end
    end
  end

  def edit
    @recurring_frequency = RecurringFrequency.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def update
    @recurring_frequency = RecurringFrequency.find(params[:id])

    respond_to do |format|
      if @recurring_frequency.update_attributes(recurring_frequency_params)
        format.js
        format.html { redirect_to @recurring_frequency, notice: 'Recurring Frequency was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @recurring_frequency.errors, status: :unprocessable_entity }
      end
    end

  end

  def destroy_bulk
    RecurringFrequency.where(id: params[:frequency_ids]).destroy_all
    render json: {notice: t('views.recurring_frequencies.deleted_msg')}, status: :ok
  end

  private

  def recurring_frequency_params
    params.require(:recurring_frequency).permit(:title, :number_of_days)
  end
end
