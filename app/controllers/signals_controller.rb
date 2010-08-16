class SignalsController < ApplicationController

	def check
		# only declench filter
		render :json => {}.to_json
	end


end

