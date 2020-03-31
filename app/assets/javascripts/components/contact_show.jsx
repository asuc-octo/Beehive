class ContactShow extends React.Component {
	/**
	 * Params:
	 * 	name - Name of User
	 * 	user_type - Type of the user (eg: Graduate Student)
	 *	research_blurb - description of the type of research
	 *	has_jobs - does the user have jobs posted
	 *	jobs - HTML for rendering the list
	 */
	render(){
		return  <div class="container">
				  <h1> {this.props.name} </h1>
				  <h3 class="user_type"> {this.props.user_type} </h3>
				  <div class="card">
				    <div class="row">
				      <dl class="dl-horizontal">
				        <dt>Research Description</dt>
				        <dd> {this.props.research_blurb}</dd>
				        <dt>All Posted Projects</dt>
				        <dd>
				          {this.props.has_jobs ? <div dangerouslySetInnerHTML={{__html: this.props.jobs}}></div> : <div></div>}
				        </dd>
				      </dl>
				    </div>
				  </div>
				</div>

	}
}