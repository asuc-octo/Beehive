class ProjectList extends React.Component {
	/**
	 * Params:
	 * 	list_name - Title of card
	 * 	empty - Jobs empty?
	 *	default_message - message to display if jobs is empty
	 *	jobs - HTML for rendering the list
	 */
	render(){
		return  <div className="card">
		          <h2>{this.props.list_name}</h2>
		          {this.props.empty ? <div dangerouslySetInnerHTML={{__html: this.props.default_message}}></div> : <div dangerouslySetInnerHTML={{__html: this.props.jobs}}></div>}
			    </div>
	}
}
