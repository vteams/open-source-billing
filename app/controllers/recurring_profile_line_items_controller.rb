class RecurringProfileLineItemsController < ApplicationController
  # GET /recurring_profile_line_items
  # GET /recurring_profile_line_items.json
  def index
    @recurring_profile_line_items = RecurringProfileLineItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @recurring_profile_line_items }
    end
  end

  # GET /recurring_profile_line_items/1
  # GET /recurring_profile_line_items/1.json
  def show
    @recurring_profile_line_item = RecurringProfileLineItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @recurring_profile_line_item }
    end
  end

  # GET /recurring_profile_line_items/new
  # GET /recurring_profile_line_items/new.json
  def new
    @recurring_profile_line_item = RecurringProfileLineItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @recurring_profile_line_item }
    end
  end

  # GET /recurring_profile_line_items/1/edit
  def edit
    @recurring_profile_line_item = RecurringProfileLineItem.find(params[:id])
  end

  # POST /recurring_profile_line_items
  # POST /recurring_profile_line_items.json
  def create
    @recurring_profile_line_item = RecurringProfileLineItem.new(recurring_profile_line_items_params)

    respond_to do |format|
      if @recurring_profile_line_item.save
        format.html { redirect_to @recurring_profile_line_item, notice: 'Recurring profile line item was successfully created.' }
        format.json { render json: @recurring_profile_line_item, status: :created, location: @recurring_profile_line_item }
      else
        format.html { render action: "new" }
        format.json { render json: @recurring_profile_line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /recurring_profile_line_items/1
  # PUT /recurring_profile_line_items/1.json
  def update
    @recurring_profile_line_item = RecurringProfileLineItem.find(params[:id])

    respond_to do |format|
      if @recurring_profile_line_item.update_attributes(recurring_profile_line_items_params)
        format.html { redirect_to @recurring_profile_line_item, notice: 'Recurring profile line item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @recurring_profile_line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recurring_profile_line_items/1
  # DELETE /recurring_profile_line_items/1.json
  def destroy
    @recurring_profile_line_item = RecurringProfileLineItem.find(params[:id])
    @recurring_profile_line_item.destroy

    respond_to do |format|
      format.html { redirect_to recurring_profile_line_items_url }
      format.json { head :no_content }
    end
  end

  private

  def recurring_profile_line_items_params
    params.require(:recurring_profile_line_item).permit(:recurring_profile_id, :item_id, :item_name, :item_description, :item_unit_cost, :item_quantity, :tax_1, :tax_2, :archive_number, :archived_at, :deleted_at)
  end

end
