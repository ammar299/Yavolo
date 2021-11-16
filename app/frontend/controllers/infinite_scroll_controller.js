import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["entries", "pagination"]

    connect() {
        this.isLoading = false
    }

    onScroll(e){
        const modal_scrollTop = $(e.target).scrollTop();
        const modal_scrollHeight = $(e.target).prop('scrollHeight');
        const modal_innerHeight = $(e.target).innerHeight();
        if (modal_scrollTop + modal_innerHeight >= (modal_scrollHeight - 100)) {
            this.loadMore();
        }
    }

    loadMore() {
        let next_page = this.paginationTarget.querySelector("a[rel='next']")
        if (next_page == null || this.isLoading) { return }
        this.isLoading = true
        let url = next_page.href
        $.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                this.entriesTarget.insertAdjacentHTML('beforeend', data.raw_html)
                this.paginationTarget.innerHTML = data.pagination
                this.isLoading = false
            }
        })
    }
}