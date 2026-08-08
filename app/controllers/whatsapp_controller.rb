# frozen_string_literal: true

# A small chat app rendered as native Ruflet UI
# (Ruflet::Rails.html_app) — chat list, conversation with message bubbles,
# a message composer that posts to Rails, plus Status and Calls tabs.
class WhatsappController < ApplicationController
  layout "native"

  CONTACTS = {
    "ada"   => { name: "Ada Lovelace",   avatar: "AL", color: "bg-violet-500", last: "See you at the meetup!", time: "09:41", unread: 2 },
    "alan"  => { name: "Alan Turing",    avatar: "AT", color: "bg-emerald-500", last: "The proof checks out.",  time: "08:12", unread: 0 },
    "grace" => { name: "Grace Hopper",   avatar: "GH", color: "bg-sky-500",     last: "Nanoseconds ⚡",        time: "Yesterday", unread: 5 },
    "linus" => { name: "Linus T.",       avatar: "LT", color: "bg-amber-500",   last: "Merged to main.",       time: "Yesterday", unread: 0 }
  }.freeze

  SEED = {
    "ada"   => [["them", "Hey! Are you coming to the Ruby meetup?"], ["me", "Wouldn't miss it 🎉"], ["them", "See you at the meetup!"]],
    "alan"  => [["them", "I finished the halting analysis."], ["them", "The proof checks out."]],
    "grace" => [["me", "How small is a nanosecond really?"], ["them", "About 30cm of wire."], ["them", "Nanoseconds ⚡"]],
    "linus" => [["me", "Did the patch land?"], ["them", "Merged to main."]]
  }.freeze

  def index
    @contacts = CONTACTS
  end

  def status; end
  def calls; end

  def show
    @id = params[:id]
    @contact = CONTACTS.fetch(@id) { redirect_to("/whatsapp") and return }
    @messages = threads[@id] || SEED[@id] || []
  end

  def create_message
    @id = params[:id]
    return redirect_to("/whatsapp") unless CONTACTS.key?(@id)

    body = params[:body].to_s.strip
    if body.present?
      store = threads
      store[@id] = (store[@id] || SEED[@id] || []) + [["me", body]]
      session[:wa_threads] = store
    end
    redirect_to "/whatsapp/show/#{@id}"
  end

  private

  def threads
    session[:wa_threads] ||= {}
  end
end
